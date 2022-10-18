//
//  MemoComposeViewModel.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class MemoComposeViewModel: CommonViewModel {
    
    /// 메모쓰기에서는 빈문자열 표시
    /// 편집하기에서는 편집할 문자열 표시
    private let content: String?
    
    var initialText: Driver<String?> {
        return Observable.just(content).asDriver(onErrorJustReturn: nil)
    }
    
    let saveAction: Action<String, Void>
    let cancelAction: CocoaAction
    
    
    // 뷰 모델에서  action을 직접 구현하면 하나로 고정된다
    // 파라미터로 받으면 이전화면에서 동적으로 결정할수있다.
    init(title: String,
         content: String? = nil,
         sceneCoordinator: SceneCoordinatorType,
         storage: MemoStorageType, saveAction: Action<String, Void>? = nil,
         cancelAction: CocoaAction? = nil) {
        self.content = content
        
        self.saveAction = Action<String, Void> { input in
            if let action = saveAction {
                action.execute(input)
            }
            
            return sceneCoordinator.close(animated: true).asObservable()
                .map { _ in }
        }
        
        self.cancelAction = CocoaAction {
            if let action = cancelAction {
                action.execute(())
            }
            return sceneCoordinator.close(animated: true).asObservable()
                .map { _ in }
        }
        
        super.init(title: title,
                   sceneCoordinator: sceneCoordinator,
                   storage: storage)
    }
}

