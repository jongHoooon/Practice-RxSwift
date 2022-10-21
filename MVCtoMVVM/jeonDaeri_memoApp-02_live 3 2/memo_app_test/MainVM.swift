//
//  MainVM.swift
//  memo_app_test
//
//  Created by JongHoon on 2022/10/21.
//

import Foundation
import RxCocoa
import RxSwift
import SwipeCellKit

enum MemoAction {
    case delete(_ index: Int)
    case modify(_ index: Int, content: String)
    case add(_ memo: Memo)
    case clear
    case refresh
}


class MainVM  {
    
    var mainTitle: Observable<String>
    
    var disposeBag = DisposeBag()
    
    var memoList: BehaviorSubject<[Memo]> = BehaviorSubject<[Memo]>(value: [])
    
    //MARK: - 수정하는 액션들
    //    var deleteAction = PublishRelay<IndexPath>()
    
    var action = PublishRelay<MemoAction>()
    
    let refreshLoading = PublishRelay<Bool>()
    
    init() {
        
        mainTitle = memoList
            .map { $0.count }
            .map { "빡코딩 메모 : 작성된 메모 \($0) 개" }
        
        let memos = UserDefaultsManager.shared.getMemoList() ?? [Memo]()
        memoList.onNext(memos)
        
        //MARK: - 구독 처리
        
        action
            .subscribe(onNext: { [weak self] action in
                guard let self = self else { return }
                
                switch action {
                case .delete(let index):
                    self.deleteMemo(index)
                case .modify(let index, content: let content):
                    self.modifyMemo(index: index, content: content)
                case .add(let memo):
                    self.addMemo(with: memo)
                case .clear:
                    self.clearAllDataAndApply()
                case .refresh:
                    self.refreshMemo()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func memoAtIndex(indexPath: IndexPath) -> Memo {
        let memo = try! memoList.value()[indexPath.row]
        
        return memo
    }
    

}

//MARK: - fileprivate

fileprivate extension MainVM {
    
    /// 해당 메모를 지운다
    /// - Parameter indexToBeDeleted: 지울 메모 인덱스
    func deleteMemo(_ indexToBeDeleted: Int){
        // 저장된 데이터 가져오기
        var fetchedMemos: [Memo] = UserDefaultsManager.shared.getMemoList() ?? []
        fetchedMemos.remove(at: indexToBeDeleted)
        
        UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
        self.memoList.onNext(fetchedMemos)
    }
    
    func modifyMemo(index: Int, content: String) {
        
        // 저장된 데이터 가져오기
        let fetchedMemos: [Memo] = UserDefaultsManager.shared.getMemoList() ?? []
        
        // 가져온 데이터 수정
        fetchedMemos[index].editMemo(content: content)
        
        // 업데이트 된 데이터 저장하기
        UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
        memoList.onNext(fetchedMemos)
    }
    
    func addMemo(with data: Memo){
        print("MainVC - addMemo() called / data: \(data)")
        
        // 저장된 데이터 가져오기
        
        var fetchedMemos : [Memo] = []
        
        fetchedMemos = UserDefaultsManager.shared.getMemoList() ?? []
        
        // 가져온 데이터에 새 메모 추가하기
        fetchedMemos.append(data)
        
        // 업데이트 된 데이터 저장하기
        UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
        
        self.memoList.onNext(fetchedMemos)
    }
    
    func clearAllDataAndApply() {
        UserDefaultsManager.shared.clearMemoList()
        
        memoList.onNext([])
    }
    
    func refreshMemo() {
        let fetchedMemos: [Memo] = UserDefaultsManager.shared.getMemoList() ?? []
        memoList.onNext(fetchedMemos)
    }
}
