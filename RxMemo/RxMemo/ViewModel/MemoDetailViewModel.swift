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
            formatter.string(from: memo.insertData)
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

}
