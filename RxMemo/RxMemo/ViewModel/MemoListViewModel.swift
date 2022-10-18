//
//  MemoListViewModel.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import Foundation
import RxCocoa
import RxSwift

// 의존성 주입 initializer, bind에 사용되는 속성과 메소드
// 화면전환, 메모 저장 처리

class MemoListViewModel: CommonViewModel {
    
    var memoList: Observable<[Memo]> {
        return storage.memoList()
    }
    
}

