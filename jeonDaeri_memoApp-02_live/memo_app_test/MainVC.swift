//
//  ViewController.swift
//  memo_app_test
//
//  Created by Jeff Jeong on 2021/01/24.
//

import UIKit
import SwipeCellKit
import RxSwift
import RxCocoa
import Action
import NSObject_Rx

class MainVC: UIViewController {
    
    var mainVM = MainVM()
    
    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var writeMemoBtn: UIBarButtonItem!
    
    private lazy var refreshControl: UIRefreshControl = {
       var refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        return refreshControl
    }()
//    refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainVC - viewDidLoad() called ")

        bindViewModel()
                
        tableView.refreshControl = refreshControl

    }// viewDidLoad()
    
    func bindViewModel() {
        
        // MARK: - configureUI
        mainVM.mainTitle
            .bind(to: rx.title)
            .disposed(by: rx.disposeBag)
        
        // MARK: - configureTableView
        
        mainVM.memoList
            .bind(to: tableView.rx.items(dataSource: mainVM.dataSource))
            .disposed(by: rx.disposeBag)
        
        Observable
            .zip(tableView.rx.modelSelected(Memo.self),
                 tableView.rx.itemSelected)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                vc.tableView.deselectRow(at: data.1, animated: true)
                
                print("didSelectRowAt")
                let itemToBeDeleted = data.0.identity
                print("itemToBeDeleted: \(itemToBeDeleted)")
                self.showEditAC(memo: data.0, indexPath: data.1)
            })
            .disposed(by: rx.disposeBag)
        
        writeMemoBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showNewMemoAC()
            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemDeleted
            .bind(to: mainVM.deleteMemo.inputs)
            .disposed(by: rx.disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else { return }
                    
                    self.mainVM.refreshMemo()
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: rx.disposeBag)
    }

    /// 메모 작성창 present
    fileprivate func showNewMemoAC(){
        let ac = UIAlertController(title: "메모 추가하기", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "추가", style: .default) { [unowned ac] _ in
            guard let addedMemo = ac.textFields![0].text else {
                print("작성된 내용이 없습니다")
                return
            }
            print("addedMemo : \(addedMemo)")
            self.mainVM.addMemo(with: Memo.createNewMemo(with: addedMemo))
        }
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))

        self.present(ac, animated: true)
    }

    /// 추가 수정 얼럿 컨트롤러 보여주기
    fileprivate func showEditAC(memo: Memo, indexPath: IndexPath) {
        print("MainVC - showEditAC() called")
        let ac = UIAlertController(title: "메모 수정하기", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].text = memo.content
        

        let submitAction = UIAlertAction(title: "추가", style: .default) { [unowned ac] _ in
            guard let editedText = ac.textFields![0].text else {
                print("작성된 내용이 없습니다")
                return
            }
            print("editedMemo : \(editedText)")
            self.mainVM.editMemo(index: indexPath, content: editedText)
        }
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
}

//MARK: - 스와이프 액션들

//extension MainVC : SwipeTableViewCellDelegate {
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//
//        switch orientation {
//        case .right:
//            let deleteAction = SwipeAction(style: .destructive, title: "지우기") { [weak self] action, indexPath in
//                guard let self = self else { return }
//              // handle action by updating model with deletion
//                print("지우는 액션")
//                self.mainVM.deleteMemo(at: indexPath.row)
//            }
//            deleteAction.image = UIImage(systemName: "trash.fill")
//            return [deleteAction]
//        case .left:
//            let editAction = SwipeAction(style: .default, title: "수정하기") { [weak self] action, indexPath in
//                guard let self = self else { return }
//              // handle action by updating model with deletion
//                print("수정하는 액션")
//    //            self.deleteMemo(at: indexPath.row)
//            }
//            // customize the action appearance
//            editAction.image = UIImage(systemName: "pencil.circle")
//            return [editAction]
//        }
//    }
//}
