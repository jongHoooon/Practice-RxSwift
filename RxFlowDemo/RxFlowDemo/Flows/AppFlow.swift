//
//  AppFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-08.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import UIKit
import RxFlow
import RxCocoa
import RxSwift

class AppFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  
  private lazy var rootViewController: UINavigationController = {
    let viewController = UINavigationController()
    viewController.setNavigationBarHidden(true, animated: true)
    return viewController
  }()
  
  private let services: AppServices
  
  init(services: AppServices) {
    self.services = services
  }
  
  deinit {
    print("\(type(of: self)): \(#function)")
  }
  
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? DemoStep else { return .none }
    
    switch step {
    case .dashboardIsRequired:
      return self.navigationToDashboardScreen()
    case .onboardingIsRequired:
      return self.navigationToOnboardingScreen()
    case .onboardingIsComplete:
      return self.dismissOnboarding()
    default:
      return .none
    }
  }
  
  // TabBar
  private func navigationToDashboardScreen() -> FlowContributors {
    
    // dashboardFlow 인스턴스화(TabBar)
    let dashboardFlow = DashboardFlow(withServices: self.services)
    
    Flows.use(dashboardFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        self.rootViewController.pushViewController(root, animated: false)
      }
    }
    
    // 1개의 Flow 전달(step한개 전달)
    return .one(flowContributor: .contribute(
      withNextPresentable: dashboardFlow,
      withNextStepper: OneStepper(withSingleStep: DemoStep.dashboardIsRequired)
    ))
  }
  
  // 로그인 진행 화면으로
  private func navigationToOnboardingScreen() -> FlowContributors {
    
    let onboardingScreen = OnboardingFlow(withServices: self.services)
    
    Flows.use(onboardingScreen, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        self.rootViewController.pushViewController(root, animated: true)
      }
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: onboardingScreen,
      withNextStepper: OneStepper(withSingleStep: DemoStep.loginIsRequired)
    ))
  }
  
  // 화면 dismiss
  private func dismissOnboarding() -> FlowContributors {
    if let onboardingViewController = self.rootViewController.presentedViewController {
      onboardingViewController.dismiss(animated: true)
    }
    return .none
  }
}

class AppStepper: Stepper {
  
  let steps = PublishRelay<Step>()
  private let appServices: AppServices
  private let disposeBag = DisposeBag()
  
  init(withServices services: AppServices) {
    self.appServices = services
  }
  
  var initialStep: Step{
    return DemoStep.dashboardIsRequired
  }
  
  /// callback used to emit steps once the FlowCoordinator is ready to listen to them to contribute to the Flow
  func readyToEmitSteps() {
    self.appServices
      .preferencesService.rx
      .isOnboarded
      .map { $0 ? DemoStep.onboardingIsComplete : DemoStep.onboardingIsRequired }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
  }
  // 로그인 상태인지 확인
}
