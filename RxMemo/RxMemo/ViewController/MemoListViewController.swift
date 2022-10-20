//
//  MemoListViewController.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class MemoListViewController: UIViewController, ViewModelBindableType {
    
    @IBOutlet weak var listTableView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var viewModel: MemoListViewModel!

    func bindViewModel() {
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.memoList
            .bind(to: listTableView.rx.items(cellIdentifier: "cell")) { row, memo, cell in
                cell.textLabel?.text = memo.content
            }
            .disposed(by: rx.disposeBag)
        
        addButton.rx.action = viewModel.makeCreateAction()
        
        Observable
            .zip(
                listTableView.rx.modelSelected(Memo.self),
                listTableView.rx.itemSelected
            )
            .withUnretained(self)
            // 클로저에서 viewController에 접근할때 캡쳐리스트 사용
            .do(onNext: { (vc, data) in
                vc.listTableView.deselectRow(
                    at: data.1,
                    animated: true
                )
            })
            .map { return $1.0 }
            .bind(to: viewModel.detailAction.inputs)
            .disposed(by: rx.disposeBag)
        
        listTableView.rx.modelDeleted(Memo.self)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.deleteAction.inputs)
            .disposed(by: rx.disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
