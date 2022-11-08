//
//  SettingFlow.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import RxFlow
import RxRelay

struct SettingStepper: Stepper {
  let steps: PublishRelay<Step> = .init()
  
  var initialStep: Step {
    return SampleStep.settingIsRequired
  }
}

final class SettingFlow: Flow {
  
  // MARK: - Property
  
  var root: Presentable {
    return self.rootViewController
  }
  
  let stepper: SettingStepper
  private let provider: ServiceProviderType
  private let rootViewController = UINavigationController()
  
  // MARK: - Init
  
  init(with provider: ServiceProviderType,
       Stepper: SettingStepper) {
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

private extension SettingFlow {
  
}
