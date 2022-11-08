//
//  TaskListViewReactor.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

// RxDataSources 사용
typealias TaskListSection = SectionModel<Void, TaskCellReactor>

final class TaskListViewReactor: Reactor {

  // 화면전환은 밖에서
  
  enum Action {
    case refresh                            // viewDidLoad시
    case toggleEditing                      // Edit btn 클릭시
    case toggleTaskDone(IndexPath)          // tableView Cell 클릭시
    case deleteTask(IndexPath)              // rx.itemDeleted
    case moveTask(IndexPath, IndexPath)     // rx.itemMoved
  }

  enum Mutation {
    case toggleEditing
    case setSections([TaskListSection])
    case insertSectionItem(IndexPath, TaskListSection.Item)
    case updateSectionItem(IndexPath, TaskListSection.Item)
    case deleteSectionItem(IndexPath)
    case moveSectionItem(IndexPath, IndexPath)
  }

  struct State {
    var isEditing: Bool                      // 편집 상태 표시
    var sections: [TaskListSection]          // table view sections
  }

  // MARK: - Property
  let provider: ServiceProviderType
  let initialState: State

  init(provider: ServiceProviderType) {
    self.provider = provider
    self.initialState = State(
      isEditing: false,
      sections: [TaskListSection(model: Void(), items: [])]
    )
  }

  // 원래 mutate
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refresh:
      return self.provider.taskService.fetchTasks()
        .map { tasks in
          let sectionItems = tasks.map(TaskCellReactor.init)
          let section = TaskListSection(model: Void(), items: sectionItems)
          return .setSections([section])
        }

    case .toggleEditing:
      return .just(.toggleEditing)

    case let .toggleTaskDone(indexPath):
      let task = self.currentState.sections[indexPath].currentState
      if !task.isDone {
        return self.provider.taskService.markAsDone(taskID: task.id).flatMap { _ in Observable.empty() }
      } else {
        return self.provider.taskService.markAsUndone(taskID: task.id).flatMap { _ in Observable.empty() }
      }

    case let .deleteTask(indexPath):
      // service에서 처리
      let task = self.currentState.sections[indexPath].currentState
      return self.provider.taskService.delete(taskID: task.id).flatMap { _ in Observable.empty() }

    case let .moveTask(sourceIndexPath, destinationIndexPath):
      let task = self.currentState.sections[sourceIndexPath].currentState
      return self.provider.taskService.move(taskID: task.id, to: destinationIndexPath.item)
        .flatMap { _ in Observable.empty() }
    }
  }

  // Action 없이 mutation 발생한다.
  // 원래 있던 mutate()에서 발생한 이벤트와 TaskService().event에 있는 것을 같이 방출하는 메소드
  //
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    
    let taskEventMutation = self.provider.taskService.event
      .flatMap { [weak self] taskEvent -> Observable<Mutation> in
        self?.mutate(taskEvent: taskEvent) ?? .empty()
      }
    return Observable.of(mutation, taskEventMutation).merge()
  }
  

  // action을 변수로 받지 않고 TaskEvent를 변수로 받는다.
  // action 별로 mutation 수행
  private func mutate(taskEvent: TaskEvent) -> Observable<Mutation> {
    let state = self.currentState
    
    switch taskEvent {
    case let .create(task):
      let indexPath = IndexPath(item: 0, section: 0)
      let reactor = TaskCellReactor(task: task)
      return .just(.insertSectionItem(indexPath, reactor))

    case let .update(task):
      guard let indexPath = self.indexPath(forTaskID: task.id, from: state) else { return .empty() }
      let reactor = TaskCellReactor(task: task)
      return .just(.updateSectionItem(indexPath, reactor))

    case let .delete(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      return .just(.deleteSectionItem(indexPath))

    case let .move(id, index):
      guard let sourceIndexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      let destinationIndexPath = IndexPath(item: index, section: 0)
      return .just(.moveSectionItem(sourceIndexPath, destinationIndexPath))

    case let .markAsDone(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      var task = state.sections[indexPath].currentState
      task.isDone = true
      let reactor = TaskCellReactor(task: task)
      return .just(.updateSectionItem(indexPath, reactor))

    case let .markAsUndone(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      var task = state.sections[indexPath].currentState
      task.isDone = false
      let reactor = TaskCellReactor(task: task)
      return .just(.updateSectionItem(indexPath, reactor))
    }
  }

  // 화면에 보여지는 거 수정
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setSections(sections):
      state.sections = sections
      return state

    case .toggleEditing:
      state.isEditing = !state.isEditing
      return state

    case let .insertSectionItem(indexPath, sectionItem):
      state.sections.insert(sectionItem, at: indexPath)
      return state

    case let .updateSectionItem(indexPath, sectionItem):
      state.sections[indexPath] = sectionItem
      return state

    case let .deleteSectionItem(indexPath):
      state.sections.remove(at: indexPath)
      return state

    case let .moveSectionItem(sourceIndexPath, destinationIndexPath):
      let sectionItem = state.sections.remove(at: sourceIndexPath)
      state.sections.insert(sectionItem, at: destinationIndexPath)
      return state
    }
  }

  private func indexPath(forTaskID taskID: String, from state: State) -> IndexPath? {
    let section = 0
    let item = state.sections[section].items.index { reactor in reactor.currentState.id == taskID }
    if let item = item {
      return IndexPath(item: item, section: section)
    } else {
      return nil
    }
  }

  func reactorForCreatingTask() -> TaskEditViewReactor {
    return TaskEditViewReactor(provider: self.provider, mode: .new)
  }

  func reactorForEditingTask(_ taskCellReactor: TaskCellReactor) -> TaskEditViewReactor {
    let task = taskCellReactor.currentState
    return TaskEditViewReactor(provider: self.provider, mode: .edit(task))
  }
}


// VC에서 action 발생 -> Reactor에서 action에 맞는 mutation실행 service 한테 요청 -> service에서 업데이트 후 내부 PublishSubject에 onNext 발생 -> Reactor에서 구독하고 있다가 event onNext 오면 mutate 시킨 후 reduce실행
