//
//  SceneDelegate.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import UIKit
import RxSwift
import RxFlow

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private let coordinaotr: FlowCoordinator = .init()
  private let disposeBag: DisposeBag = .init()

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    
  }
  
  private func coordinateToAppFLow(with windowScene: UIWindowScene) {
    let window = UIWindow(windowScene: windowScene)
    self.window = window
    
    let provider: ServiceProviderType = ServiceProvider()
    let appFlow = AppFlow(with: window, and: provider)
    let appStepper = AppStepper(provider: provider)
    
    self.coordinaotr.coordinate(flow: appFlow, with: appStepper)

    window.backgroundColor = .systemBackground
    window.makeKeyAndVisible()
  }

  private func coordinatorLogStart() {
    coordinaotr.rx.willNavigate
      .subscribe(onNext: { flow, step in
        let currentFlow = "\(flow)".split(separator: ".").last ?? "no flow"
        print("➡️ will navigate to flow = \(currentFlow) and step = \(step)")
      })
      .disposed(by: disposeBag)
  }
}

