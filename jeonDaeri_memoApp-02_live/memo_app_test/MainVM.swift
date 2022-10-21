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

struct MainVM {
    
    let title = Observable<String>.just("빡코딩 메모")
    var memoList: Observable<[MemoSectionModel]> {
        let memos = UserDefaultsManager.shared.getMemoList() ?? [Memo]()
        return Observable.from([[MemoSectionModel(model: 0, items: memos)]])
    }
    
    // MARK: - configDatasource
    let dataSource: RxTableViewSectionedAnimatedDataSource<MemoSectionModel> = {
        let dataSource =  RxTableViewSectionedAnimatedDataSource<MemoSectionModel> { dataSource, tableView, indexPath, memo -> UITableViewCell in
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MemoItemCell.reuseIdentifier,
                for: indexPath
            ) as! MemoItemCell
        
            cell.updateUI(with: memo)
            
            return cell
        }
        
        return dataSource
    }()
}
