//
//  AppFlow.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import UIKit

import RxFlow
import RxCocoa
import RxSwift

class AppStepper: Stepper {
  
  let steps: PublishRelay<Step> = .init()
  private let provider: ServiceProviderType
  private let disposeBag: DisposeBag = .init()
  
  init(provider: ServiceProviderType) {
    self.provider = provider
    
  }
  
  func readyToEmitSteps() {
    provider.loginService.didLoginObservable
      .map { $0 ? SampleStep.loginIsCompleted : SampleStep.loginIsRequired }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}

// Flow는 AnyObject를 준수하므로 class로 선언해야한다.
final class AppFlow: Flow {
  var root: Presentable {
    return self.rootWindow
  }
  
  private let rootWindow: UIWindow
  private let provider: ServiceProviderType
  
  init(
    with window: UIWindow,
    and service: ServiceProviderType
  ) {
    self.rootWindow = window
    self.provider = service
  }
  
  deinit {
    print("\(type(of: self)): \(#function)")
  }

  /// 1. 바로 메인으로 이동
  /// 2. 로그인 필요
  /// 3. 로그인 완료
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? SampleStep else { return .none }
    
    switch step {
    
    /// 앱을 처음 시작해 로그인이 되어잇지 않을겨우 로그인 화면으로 이동
    case .loginIsRequired:
      return self.coordinateToLoginVC()
      
    /// mainTabBarIsRequired 호출 시 MainFlow와 nextStep을 넘겨준다.
    case .mainTabBarIsRequired, .loginIsCompleted:
      return coordinateToMainVC()
      
    default:
      return .none
    }
  }
  
  private func coordinateToLoginVC() -> FlowContributors {
    let loginFlow = LoginFlow(with: self.provider)
    
    Flows.use(loginFlow, when: .created) { [unowned self] root in
      self.rootWindow.rootViewController = root
    }
    
    let nextStep = OneStepper(withSingleStep: SampleStep.loginIsRequired)
    
    return .one(flowContributor: .contribute(withNextPresentable: loginFlow,
                                             withNextStepper: nextStep))
  }
  
  private func coordinateToMainVC() -> FlowContributors {
    let mainFlow = MainFlow(with: self.provider)
    
    let nexStep = OneStepper(withSingleStep: SampleStep.mainTabBarIsRequired)
    
    return .one(flowContributor: .contribute(withNextPresentable: mainFlow,
                                             withNextStepper: nexStep))
  }
}
