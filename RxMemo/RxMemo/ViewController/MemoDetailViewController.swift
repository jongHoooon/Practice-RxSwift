//
//  MemoDetailViewController.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import UIKit

class MemoDetailViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoDetailViewModel!
    
    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    func bindViewModel() {
        
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.contents
            .bind(to: contentTableView.rx.items) { tableView, row, value in
                switch row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell")!
                    cell.textLabel?.text = value
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell")!
                    cell.textLabel?.text = value
                    return cell
                default:
                    fatalError()
                }
            }
            .disposed(by: rx.disposeBag)
        
        editButton.rx.action = viewModel.makeEditAction()
        
        var backButton = UIBarButtonItem(
            title: nil,
            style: .done,
            target: nil,
            action: nil)
        
        viewModel.title
            .drive(backButton.rx.title)
            .disposed(by: rx.disposeBag)
        
        backButton.rx.action = viewModel.popAction
//        navigationItem.backBarButtonItem = backButton // backButton의 action은 기본 버튼으로 전달돼 leftItem 사용
//        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
