//
//  LoginVC.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import UIKit

import RxFlow
import RxCocoa
import ReactorKit
import Then
import SnapKit

final class LoginVC: UIViewController {
  
  var disposeBag: DisposeBag = .init()
  
  private let loginButton: UIButton = UIButton().then {
    $0.setTitle("login", for: .normal)
    $0.backgroundColor = .black
  }
  
  init(with reactor: LoginReactor) {
    super.init(nibName: nil, bundle: nil)
    
    self.reactor = reactor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("➡️ \(type(of: self)): \(#function)")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUI()
  }
}

private extension LoginVC {
  func setUI() {
    self.title = "Login"
    view.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    
    view.addSubview(loginButton)
    loginButton.snp.makeConstraints {
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
      $0.height.equalTo(50)
    }
  }
}

// MARK: - Bind

extension LoginVC: View {
  
  func bind(reactor: LoginReactor) {
    
  }
}
