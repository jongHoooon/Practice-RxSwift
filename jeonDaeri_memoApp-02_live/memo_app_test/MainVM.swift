//
//  MainVM.swift
//  memo_app_test
//
//  Created by JongHoon on 2022/10/21.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import Action

typealias MemoSectionModel = AnimatableSectionModel<Int, Memo>

class MainVM {
    
    var mainTitle: Observable<String>
    
    var memoList: BehaviorSubject<[MemoSectionModel]> = BehaviorSubject<[MemoSectionModel]>(value: [])

    let refreshLoading = PublishRelay<Bool>()

    init() {
        
        mainTitle = memoList
            .compactMap { $0.first }
            .map { $0.items.count }
            .map { "빡코딩 메모 : 작성된 메모 \($0) 개" }
        
        let memos = UserDefaultsManager.shared.getMemoList() ?? [Memo]()
        memoList.onNext([MemoSectionModel(model: 0, items: memos)])
        
    }
    
    // MARK: - configDatasource
    let dataSource: RxTableViewSectionedAnimatedDataSource<MemoSectionModel> = {
        let dataSource =  RxTableViewSectionedAnimatedDataSource<MemoSectionModel> { dataSource, tableView, indexPath, memo -> UITableViewCell in
             
            // MARK: - configTableView
            let cellNib = UINib(nibName: MemoItemCell.reuseIdentifier, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: MemoItemCell.reuseIdentifier)
            
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 100
            
            
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MemoItemCell.reuseIdentifier,
                for: indexPath
            ) as! MemoItemCell
        
            cell.updateUI(with: memo)
            
            return cell
        }
        
        return dataSource
    }()
    
    func addMemo(with data: Memo){
        print("MainVC - addMemo() called / data: \(data)")

        // 저장된 데이터 가져오기

        var fetchedMemos : [Memo] = []

        fetchedMemos = UserDefaultsManager.shared.getMemoList() ?? []

        // 가져온 데이터에 새 메모 추가하기
        fetchedMemos.append(data)

        // 업데이트 된 데이터 저장하기
        UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
        
        memoList.onNext([MemoSectionModel(model: 0, items: fetchedMemos)])
    }
    
    func editMemo(index: IndexPath, content: String) {
        
        // 저장된 데이터 가져오기
        let fetchedMemos: [Memo] = UserDefaultsManager.shared.getMemoList() ?? []
        
        // 가져온 데이터 수정
        fetchedMemos[index.row].editMemo(content: content)
    
        // 업데이트 된 데이터 저장하기
        UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
        memoList.onNext([MemoSectionModel(model: 0, items: fetchedMemos)])
    }
    
    lazy var deleteMemo: Action<IndexPath, Void> = {
    
        return Action { [weak self] indexPath in
            
            guard let self = self else { return Observable.empty() }
            
            // 저장된 데이터 가져오기
            var fetchedMemos: [Memo] = UserDefaultsManager.shared.getMemoList() ?? []
            fetchedMemos.remove(at: indexPath.row)
            
            UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
            self.memoList.onNext([MemoSectionModel(model: 0, items: fetchedMemos)])
            
            return Observable.empty()
        }
        
    }()
    
    func clearAllDataAndApply() {
        UserDefaultsManager.shared.clearMemoList()
        
        memoList.onNext([MemoSectionModel(model: 0, items: [])])
    }
    
    func refreshMemo() {
        let fetchedMemos: [Memo] = UserDefaultsManager.shared.getMemoList() ?? []
        memoList.onNext([MemoSectionModel(model: 0, items: fetchedMemos)])
    }
    
}
