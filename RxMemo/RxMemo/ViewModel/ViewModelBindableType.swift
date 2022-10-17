//
//  ViewModelBindableType.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import UIKit

protocol ViewModelBindableType {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
}

/// ViewController에서 bindViewModel을 직접 호출하지 않게 해준다.
extension ViewModelBindableType where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        
        bindViewModel()
    }
}
