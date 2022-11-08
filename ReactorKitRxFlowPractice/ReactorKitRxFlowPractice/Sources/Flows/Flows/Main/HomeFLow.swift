//
//  HomeFLow.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import RxFlow
import RxRelay

struct HomeStepper: Stepper {
  let steps: PublishRelay<Step> = .init()
  
  var initialStep: Step {
    return SampleStep.homeIsRequired
  }
}

final class HomeFlow: Flow {
  
  // MARK: - Property
  
  var root: Presentable {
    return self.rootViewController
  }
  
  let stepper: HomeStepper
  private let provider: ServiceProviderType
  private let rootViewController = UINavigationController()
  
  // MARK: - Init
  
  init(with provider: ServiceProviderType,
       Stepper: HomeStepper) {
    self.provider = provider
    self.stepper = Stepper
  }
  
  deinit {
      print("➡️ \(type(of: self)): \(#function)")
  }

  // MARK: - Naviget
  
  func navigate(to step: Step) -> FlowContributors {
    .none
  }
}

// MARK: - Method

private extension HomeFlow {
  
}
