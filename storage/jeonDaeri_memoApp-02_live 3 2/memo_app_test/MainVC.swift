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
import NSObject_Rx

private extension Reactive where Base: MainVC {
    
    var memos: Binder<[Memo]> {
        return Binder(base) { mainVC, memos in
            
            mainVC.setDataAndApply(with: memos, true)
        }
    }
}

class MainVC: UIViewController {
    
    var mainVM = MainVM()
    
    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var writeMemoBtn: UIBarButtonItem!
    @IBOutlet var clearAllBtn: UIBarButtonItem!
    
    private lazy var refreshControl: UIRefreshControl = {
       var refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        return refreshControl
    }()
    
    // 데이터 소스 - 기존의 uitableViewDataSource를 대체함
    private var dataSource : UITableViewDiffableDataSource<Section, Memo>!
    
    // 스냅샷 - 현재 데이터 상태
    private var snapshot : NSDiffableDataSourceSnapshot<Section, Memo>!
       
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainVC - viewDidLoad() called ")

        configDatasource()
        
        bindViewModel()
        
        tableView.refreshControl = refreshControl

    }// viewDidLoad()
    
    func bindViewModel() {
        
        // memo 개수 title에 출력
        mainVM.mainTitle
            .bind(to: rx.title)
            .disposed(by: rx.disposeBag)
        
        // VM의 memoList VC에 연결
        mainVM
            .memoList
            .observe(on: MainScheduler.instance)
            .bind(to: self.rx.memos)
            .disposed(by: rx.disposeBag)
        
        writeMemoBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showNewMemoAC()
            })
            .disposed(by: rx.disposeBag)
        
        clearAllBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mainVM.action.accept(.clear)
            })
            .disposed(by: rx.disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else { return }
                    
                    self.mainVM.action.accept(.refresh)
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: rx.disposeBag)
        
    }
}

//MARK: - 스와이프 액션들

extension MainVC : SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .destructive, title: "지우기") { [weak self] action, indexPath in
                guard let self = self else { return }
                
                // 뷰모델에 알리기
                self.mainVM.action.accept(.delete(indexPath.row))
                
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            return [deleteAction]
        case .left:
            let editAction = SwipeAction(style: .default, title: "수정하기") { [weak self] action, indexPath in
                guard let self = self else { return }
                
                self.showModifyAC(indexPath: indexPath)
            }
            
            // customize the action appearance
            editAction.image = UIImage(systemName: "pencil.circle")
            return [editAction]
        }
    }
}

// MARK: - fileprivate

fileprivate extension MainVC {
    
    // MARK: - DataSource 관련
    
    /// 데이터 소스 초기 세팅
    func configDatasource(){
        print("MainVC - configDatasource() called")
        
        let memoNib = UINib(nibName: MemoItemCell.reuseIdentifier, bundle: Bundle.main)
        
        self.tableView.register(memoNib, forCellReuseIdentifier: MemoItemCell.reuseIdentifier)
            
        dataSource = UITableViewDiffableDataSource<Section, Memo>(tableView: self.tableView, cellProvider: { (tableView: UITableView, indexPath: IndexPath, item: Memo) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MemoItemCell.reuseIdentifier, for: indexPath) as! MemoItemCell
            cell.updateUI(with: item, self)

            return cell
        })
    }
    
    /// reload 역할
    func setDataAndApply(with data: [Memo], _ animated: Bool){
        print("MainVC - setDataAndApply() called / data: \(data.count)")
        data.forEach{ print($0.info) }

        // 스냅샷 준비
        // 빈 스냅샷
        snapshot = NSDiffableDataSourceSnapshot<Section, Memo>()

        // 섹션 추가
        snapshot.appendSections([.normal])

        // 방금 추가한 섹션에 아이템 넣기
        snapshot.appendItems(data, toSection: .normal)

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - alert창 present
    
    /// 메모작성 alert present
    func showNewMemoAC(){
        let ac = UIAlertController(title: "메모 추가하기", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "추가", style: .default) { [unowned ac] _ in
            guard let addedMemo = ac.textFields![0].text else {
                print("작성된 내용이 없습니다")
                return
            }
            print("addedMemo : \(addedMemo)")
            self.mainVM.action.accept(.add(Memo.createNewMemo(with: addedMemo)))
        }
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))

        self.present(ac, animated: true)
    }

    /// 수정 alert present
    func showModifyAC(indexPath: IndexPath) {
        print("MainVC - showEditAC() called")
        let memo = mainVM.memoAtIndex(indexPath: indexPath)
        
        let ac = UIAlertController(title: "메모 수정하기", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].text = memo.content
        

        let submitAction = UIAlertAction(title: "추가", style: .default) { [unowned ac] _ in
            guard let editedText = ac.textFields![0].text else {
                print("작성된 내용이 없습니다")
                return
            }
            self.mainVM.action.accept(.modify(indexPath.row, content: editedText))
        }
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
}
