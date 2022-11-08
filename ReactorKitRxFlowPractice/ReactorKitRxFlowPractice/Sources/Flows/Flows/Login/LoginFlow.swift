//
//  LoginFlow.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import RxFlow

final class LoginFlow: Flow {
    
  var root: Presentable {
    return self.rootViewController
  }
  
  private let rootViewController: UINavigationController = .init()
  private let provider: ServiceProviderType

  
  
  init(with provider: ServiceProviderType) {
    self.provider = provider
  }
  
  func navigate(to step: Step) -> FlowContributors {
    return .none
  }
}
