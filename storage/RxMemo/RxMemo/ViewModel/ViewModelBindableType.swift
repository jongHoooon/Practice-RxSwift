//
//  ViewModelBindableType.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import UIKit

/// ViewController에서 bindViewModel을 호출해주고 viewModel을 주입해준다.
protocol ViewModelBindableType {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
}

extension ViewModelBindableType where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        
        bindViewModel()
    }
}
