//
//  SceneCoordinatorType.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import RxSwift
import Foundation

protocol SceneCoordinatorType {
    @discardableResult
    func transition(to scene: Scene,
                    using style: TransitionStyle,
                    animated: Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool) -> Completable
}
