//
//  TransitionModel.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import Foundation

enum TransitionStyle {
    case root
    case push
    case modal
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}


