//
//  MainVM.swift
//  memo_app_test
//
//  Created by JongHoon on 2022/10/20.
//

import Foundation
import RxCocoa
import RxSwift
import Action

final class MainVM {
    let title = Driver<String>.just("빡코딩 메모")
        
    var memoList: Observable<[Memo]?> {
        UserDefaultsManager.shared.getMemoList()
    }
    
}
