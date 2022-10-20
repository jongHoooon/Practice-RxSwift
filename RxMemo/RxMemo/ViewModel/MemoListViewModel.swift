//
//  MemoListViewModel.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import Action

// 의존성 주입 initializer, bind에 사용되는 속성과 메소드
// 화면전환, 메모 저장 처리

typealias MemoSectionModel = AnimatableSectionModel<Int, Memo>

class MemoListViewModel: CommonViewModel {
    
    var memoList: Observable<[MemoSectionModel]> {
        return storage.memoList()
    }
    
    let dataSource: RxTableViewSectionedAnimatedDataSource<MemoSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<MemoSectionModel>(configureCell: {
            dataSource, tableView, indexPath, memo -> UITableViewCell in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = memo.content
            return cell
        })
        
        ds.canEditRowAtIndexPath = { _, _ in return true }
        
        return ds
    }()
    
    func makeCreateAction() -> CocoaAction {
        return CocoaAction { _ in
            return self.storage.createMemo(content: "")
                .flatMap { memo -> Observable<Void> in
                    
                    let composeViewModel = MemoComposeViewModel(
                        title: "새 메모",
                        sceneCoordinator: self.sceneCoordinator,
                        storage: self.storage,
                        saveAction: self.performUpdate(memo: memo),
                        cancelAction: self.performCancel(memo: memo)
                    )
                    let composerScene = Scene.compose(composeViewModel)
                    return self.sceneCoordinator
                        .transition(
                            to: composerScene,
                            using: .modal,
                            animated: true
                        )
                        .asObservable()
                        .map { _ in }
                }
        }
    }
    
    func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action { input in
            return self.storage.update(memo: memo, content: input).map { _ in }
        }
    }
    
    func performCancel(memo: Memo) -> CocoaAction {
        return Action {
            return self.storage.delete(memo: memo).map { _ in }
        }
    }
    
    lazy var detailAction: Action<Memo, Void> = {
        
        return Action { memo in
                        
            let detailViewModel = MemoDetailViewModel(
                memo: memo,
                title: "메모 보기",
                sceneCoordinator: self.sceneCoordinator,
                storage: self.storage
            )
            let detailScene = Scene.detail(detailViewModel)
            
            return self.sceneCoordinator.transition(
                to: detailScene,
                using: .push,
                animated: true
            )
            .asObservable()
            .map { _ in }
        }
    }()
    
    lazy var deleteAction: Action<Memo, Void> = {
        return Action { [weak self] memo in
            
            guard let self = self else { return Observable.empty() }
            
            return self.storage.delete(memo: memo)
                .map { _ in }
        }
    }()
}
