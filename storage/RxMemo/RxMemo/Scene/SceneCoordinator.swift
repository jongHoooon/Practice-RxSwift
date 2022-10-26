//
//  SceneCoordinator.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import Foundation
import RxSwift
import RxCocoa

class SceneCoordinator: SceneCoordinatorType {
    
    private let bag = DisposeBag()
    
    private var window: UIWindow
    private var currentVC: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene,
                    using style: TransitionStyle,
                    animated: Bool) -> Completable {
        
        ///  화면전환 성공 실패만 방출한다, next event는 방출하지 않음
        let subject = PublishSubject<Never>()
        
        let target = scene.instantiate()
        
        switch style {
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
            subject.onCompleted()
            
        case .push:
                guard let nav = currentVC.navigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            nav.pushViewController(target, animated: animated)
            currentVC = target.sceneViewController
            subject.onCompleted()
            
        case .modal:
            currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
        }
        
        return subject.asCompletable()
    }
    
    #warning("subject 사용해서 구현해보기")
    @discardableResult
    func close(animated: Bool) -> Completable {
        
        return Completable.create { [unowned self] completable in
            
            if let presentingVC = self.currentVC.presentingViewController {
                self.currentVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC.sceneViewController
                    completable(.completed)
                }
            }
            
            else if let nav = self.currentVC.navigationController {
                guard nav.popViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                self.currentVC = nav.viewControllers.last!.sceneViewController
                completable(.completed)
            }
            else {
                completable(.error(TransitionError.unknown))
            }
            return Disposables.create()
        }
    }
}
