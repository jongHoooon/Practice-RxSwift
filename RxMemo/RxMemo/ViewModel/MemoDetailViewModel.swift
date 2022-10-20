//
//  MemoDetailViewModel.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import Foundation
import RxCocoa
import RxSwift
import Action
import NSObject_Rx

class MemoDetailViewModel: CommonViewModel {
    
    let memo: Memo
    
    private var formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_kr")
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()
    
    var contents: BehaviorSubject<[String]>
    
    init(memo: Memo,
         title: String,
         sceneCoordinator: SceneCoordinatorType,
         storage: MemoStorageType) {
        self.memo = memo
        
        contents = BehaviorSubject<[String]>(value: [
            memo.content,
            formatter.string(from: memo.insertDate)
        ])
        
        super.init(title: title,
                   sceneCoordinator: sceneCoordinator,
                   storage: storage)
    }
    
    
    lazy var popAction = CocoaAction { [unowned self] in
        return self.sceneCoordinator.close(animated: true)
            .asObservable()
            .map { _ in }
    }
    
    /// composerViewModel로 전달한다
    func performUpdate(memo: Memo) -> Action<String, Void> {
        return Action { [weak self] input in
            
            guard let self = self else { return Observable.empty() }
            
            self.storage.update(memo: memo, content: input)
                .map {
                    
                    print($0.content)

    
                    return [$0.content, self.formatter.string(from: $0.insertDate)]
                    
                }
                .bind(onNext: { self.contents.onNext($0)})
                .disposed(by: self.rx.disposeBag)
            
            
            return Observable.empty()
        }
    }
    
    func makeEditAction() -> CocoaAction {
        return CocoaAction { [weak self] _ in
            
            guard let self = self else { return Observable<Void>.empty() }
            
            let composeViewModel = MemoComposeViewModel(
                title: "메모 편집",
                content: self.memo.content,
                sceneCoordinator: self.sceneCoordinator,
                storage: self.storage,
                saveAction: self.performUpdate(memo: self.memo)
            )
            
            let composeScene = Scene.compose(composeViewModel)
            
            return self.sceneCoordinator.transition(
                to: composeScene,
                using: .modal,
                animated: true
            )
            .asObservable()
            .map { _ in }
        }
    }
    
    func makeDeleteAction() -> CocoaAction {
        return Action { [weak self] input in
            guard let self = self else { return Observable.empty() }
            
            self.storage.delete(memo: self.memo)
            
            return self.sceneCoordinator.close(animated: true)
                .asObservable()
                .map { _ in }
        }
    }
    
//    func makeShareAction() -> CocoaAction {
//        return CocoaAction { [weak self] in
//
//            guard let self = self else { return Observable<Void>.empty() }
//
//            let memo = self.memo.content
//            let activityVC = UIActivityViewController(
//                activityItems: [memo],
//                applicationActivities: nil
//            )
//
//            return Observable.just(activityVC)
//                .asObservable()
//                .map { _ in }
//        }
//    }

}
