//
//  MainFlow.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import RxFlow

final class MainFlow: Flow {
  
  enum TabIndex: Int {
    case home = 0
    case middle = 1
    case setting = 2
  }
  
  var root: Presentable {
    return self.rootViewController
  }
  
  private let rootViewController: UITabBarController = .init()
  private let provider: ServiceProviderType
  private let homeFlow: HomeFlow
  private let middleFlow: MiddleFlow
  private let settingFlow: SettingFlow
  
  init(with provider: ServiceProviderType) {
    self.provider = provider
    self.homeFlow = HomeFlow(with: self.provider, Stepper: HomeStepper())
    self.middleFlow = MiddleFlow(with: self.provider, Stepper: MiddleStepper())
    self.settingFlow = SettingFlow(with: self.provider, Stepper: SettingStepper())
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? SampleStep else { return .none }
    
    switch step {
    case .loginIsRequired:
      return .end(forwardToParentFlowWithStep: SampleStep.loginIsRequired)
      
    case .mainTabBarIsRequired:
      return coordinateToMainTabBar()
      
    case .middleIsRequiredAgain:
      return coordinateToMiddle(step: step)
      
    case let .settingAndAlertIsRequired(message):
      return coordinateToSetting(with: message)
      
    default:
        return .none
    }
  }
}

private extension MainFlow {
  
  func coordinateToMainTabBar() -> FlowContributors {
    
    // 각각의 Flow들이 created되었을 때 root들을 가져와서 tabbar에 세팅해준다.
    Flows.use(
      homeFlow,
      middleFlow,
      settingFlow,
      when: .created
    ) { [unowned self] (
      root1: UINavigationController,
      root2: UINavigationController,
      root3: UINavigationController
    ) in
      
      let homeImage: UIImage? = UIImage(named: "home")
      let middleImage: UIImage? = UIImage(named: "middle")
      let settingImage: UIImage? = UIImage(named: "setting")
      
      let homeItem: UITabBarItem = .init(
        title: "Home",
        image: homeImage,
        selectedImage: nil
      )
      let middleItem: UITabBarItem = .init(
        title: "Middle",
        image: middleImage,
        selectedImage: nil
      )
      let settingItem: UITabBarItem = .init(
        title: "Setting",
        image: settingImage,
        selectedImage: nil
      )
      
      root1.tabBarItem = homeItem
      root2.tabBarItem = middleItem
      root3.tabBarItem = settingItem
      
      self.rootViewController.setViewControllers(
        [root1, root2, root3],
        animated: true
      )
    }
    
    return .multiple(flowContributors: [
      .contribute(withNextPresentable: homeFlow, withNextStepper: homeFlow.stepper),
      .contribute(withNextPresentable: middleFlow, withNextStepper: middleFlow.stepper),
      .contribute(withNextPresentable: settingFlow, withNextStepper: settingFlow.stepper)
    ])
  }
  
  /// 탭 bar 사용하지 않고 tab 이동하기
  func coordinateToMiddle(step: Step) -> FlowContributors {
    self.rootViewController.selectedIndex = TabIndex.middle.rawValue
    return .one(flowContributor: .contribute(
      withNextPresentable: middleFlow,
      withNextStepper: OneStepper(withSingleStep: SampleStep.middleIsRequiredAgain)
    ))
  }
  
  private func coordinateToSetting(with msg: String) -> FlowContributors {
      self.rootViewController.selectedIndex = TabIndex.setting.rawValue
      return .multiple(flowContributors: [
          .contribute(
            withNextPresentable: settingFlow,
            withNextStepper: OneStepper(withSingleStep: SampleStep.settingIsRequired)),
          .contribute(
            withNextPresentable: settingFlow,
            withNextStepper: OneStepper(withSingleStep: SampleStep.alert(message: msg))
          )])
  }
}
