//
//  TaskService.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 12/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxSwift


/// Task 관련 Event
enum TaskEvent {
  case create(Task)
  case update(Task)
  case delete(id: String)
  case move(id: String, to: Int)
  case markAsDone(id: String)
  case markAsUndone(id: String)
}


protocol TaskServiceType {
  
  
  var event: PublishSubject<TaskEvent> { get }
  func fetchTasks() -> Observable<[Task]>

  @discardableResult
  func saveTasks(_ tasks: [Task]) -> Observable<Void>

  func create(title: String, memo: String?) -> Observable<Task>
  func update(taskID: String, title: String, memo: String?) -> Observable<Task>
  func delete(taskID: String) -> Observable<Task>
  func move(taskID: String, to: Int) -> Observable<Task>
  func markAsDone(taskID: String) -> Observable<Task>
  func markAsUndone(taskID: String) -> Observable<Task>
}

final class TaskService: BaseService, TaskServiceType {

  ///  transform에 사용
  let event = PublishSubject<TaskEvent>()


  func fetchTasks() -> Observable<[Task]> {
    if let savedTaskDictionaries = self.provider.userDefaultsService.value(forKey: .tasks) {
      let tasks = savedTaskDictionaries.compactMap(Task.init)
      return .just(tasks)
    }
    
    // 저장된게 없으면 실행
    let defaultTasks: [Task] = [
      Task(title: "Go to https://github.com/devxoul"),
      Task(title: "Star repositories I am intersted in"),
      Task(title: "Make a pull request"),
    ]
    // dictionary 형태로 저장
    let defaultTaskDictionaries = defaultTasks.map { $0.asDictionary() }
    self.provider.userDefaultsService.set(value: defaultTaskDictionaries, forKey: .tasks)
    return .just(defaultTasks)
  }

  @discardableResult
  /// create, update, delete, move, mark 처리 이후 배열 다시 저장
  /// dictionary 형태로 저장
  func saveTasks(_ tasks: [Task]) -> Observable<Void> {
    let dicts = tasks.map { $0.asDictionary() }
    self.provider.userDefaultsService.set(value: dicts, forKey: .tasks)
    return .just(Void())
  }

  // 1. 저정된 tasks를 fetch
  // 2. 새로운 task 생성
  // 3. fetch한 tasks에 새로운 task 붙이고 저장 후 Observable<Task>형태로 전환
  // 4. create event 발생
  func create(title: String, memo: String?) -> Observable<Task> {
    return self.fetchTasks()
      .flatMap { [weak self] tasks -> Observable<Task> in
        guard let `self` = self else { return .empty() }
        let newTask = Task(title: title, memo: memo)

        return self.saveTasks(tasks + [newTask]).map { newTask }
      }
      // event 처리
      .do(onNext: { task in
        self.event.onNext(.create(task))
      })
  }

  // 1. 저장된 tasks fetch
  // 2. id 사용해 index 파악
  // 3. idex사용해 index위치의 tasks 업데이트 후 저장
  // 4. update event 전달
  func update(taskID: String, title: String, memo: String?) -> Observable<Task> {
    return self.fetchTasks()
      .flatMap { [weak self] tasks -> Observable<Task> in
        guard let `self` = self else { return .empty() }
        guard let index = tasks.index(where: { $0.id == taskID }) else { return .empty() }
        var tasks = tasks
        let newTask = tasks[index].with {
          $0.title = title
          $0.memo = memo
        }
        tasks[index] = newTask
        return self.saveTasks(tasks).map { newTask }
      }
      .do(onNext: { task in
        self.event.onNext(.update(task))
      })
  }

  // 1. 저장된 tasks fetch
  // 2. id 사용해 index get
  // 3. index 사용해 delete
  // 4. delete event 전달
  func delete(taskID: String) -> Observable<Task> {
    return self.fetchTasks()
      .flatMap { [weak self] tasks -> Observable<Task> in
        guard let `self` = self else { return .empty() }
        guard let index = tasks.index(where: { $0.id == taskID }) else { return .empty() }
        var tasks = tasks
        let deletedTask = tasks.remove(at: index)
        return self.saveTasks(tasks).map { deletedTask }
      }
      .do(onNext: { task in
        self.event.onNext(.delete(id: task.id))
      })
  }

  // 1. 저장된 tasks fetch
  // 2. sourceIndex get
  // 3. sourceIndex로 삭제 후 destinationIndex로 삽입
  // 4. move event 전달
  func move(taskID: String, to destinationIndex: Int) -> Observable<Task> {
    return self.fetchTasks()
      .flatMap { [weak self] tasks -> Observable<Task> in
        guard let `self` = self else { return .empty() }
        guard let sourceIndex = tasks.index(where: { $0.id == taskID }) else { return .empty() }
        var tasks = tasks
        let task = tasks.remove(at: sourceIndex)
        tasks.insert(task, at: destinationIndex)
        return self.saveTasks(tasks).map { task }
      }
      .do(onNext: { task in
        self.event.onNext(.move(id: task.id, to: destinationIndex))
      })
  }

  // 1. 저장된 tasks fetch
  // 2. id 사용해 index get
  // 3. isDone = true로 newTask 생성후 저장
  // 4. marksAsDone event 전달
  func markAsDone(taskID: String) -> Observable<Task> {
    return self.fetchTasks()
      .flatMap { [weak self] tasks -> Observable<Task> in
        guard let `self` = self else { return .empty() }
        guard let index = tasks.index(where: { $0.id == taskID }) else { return .empty() }
        var tasks = tasks
        let newTask = tasks[index].with {
          $0.isDone = true
          return
        }
        tasks[index] = newTask
        return self.saveTasks(tasks).map { newTask }
      }
      .do(onNext: { task in
        self.event.onNext(.markAsDone(id: task.id))
      })
  }

  // 1. 저장된 tasks fetch
  // 2. id 사용해 index get
  // 3. isDone = false로 newTask 생성후 저장
  // 4. marksAsDone event 전달
  func markAsUndone(taskID: String) -> Observable<Task> {
    return self.fetchTasks()
      .flatMap { [weak self] tasks -> Observable<Task> in
        guard let `self` = self else { return .empty() }
        guard let index = tasks.index(where: { $0.id == taskID }) else { return .empty() }
        var tasks = tasks
        let newTask = tasks[index].with {
          $0.isDone = false
          return
        }
        tasks[index] = newTask
        return self.saveTasks(tasks).map { newTask }
      }
      .do(onNext: { task in
        self.event.onNext(.markAsUndone(id: task.id))
      })
  }
}

