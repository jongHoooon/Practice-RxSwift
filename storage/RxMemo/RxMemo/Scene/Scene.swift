//
//  Scene.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import UIKit

/// viewController를 embed 하고 있는 controller가 아니라 실제 화면에 표시되고 있는 viewController기준으로
/// 전환을 처리하도록 구현
extension UIViewController {
    var sceneViewController: UIViewController {
        return self.children.last ?? self
    }
}

enum Scene {
    case list(MemoListViewModel)
    case detail(MemoDetailViewModel)
    case compose(MemoComposeViewModel)
}

extension Scene {
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .list(let memoListViewModel):
            
            guard let nav = storyboard.instantiateViewController(withIdentifier: "ListNav") as? UINavigationController else {
                fatalError()
            }
            
            guard var listVC = nav.viewControllers.first as? MemoListViewController else {
                fatalError()
            }
            
            DispatchQueue.main.async {
                listVC.bind(viewModel: memoListViewModel)
            }
            
            return nav
            
        case .detail(let memoDetailViewModel):
            
            guard var detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? MemoDetailViewController else {
                fatalError()
            }
            
            DispatchQueue.main.async {
                detailVC.bind(viewModel: memoDetailViewModel)
            }
            
            return detailVC
            
        case .compose(let memoComposeViewModel):
            
            guard let nav = storyboard.instantiateViewController(withIdentifier: "ComposeNav") as? UINavigationController else {
                fatalError()
            }
            
            guard var composeVC = nav.viewControllers.first as? MemoComposeViewController else {
                fatalError()
            }
            
            DispatchQueue.main.async {
                composeVC.bind(viewModel: memoComposeViewModel)
            }
            
            
            return nav
        }
    }
}
