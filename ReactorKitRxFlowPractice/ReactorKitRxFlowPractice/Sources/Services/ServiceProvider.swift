//
//  ServiceProvider.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import Foundation

protocol ServiceProviderType: class {
  var networkService: NetWorkManagerType { get }
  var loginService: LoginServiceType { get }
}

final class ServiceProvider: ServiceProviderType {
  lazy var networkService: NetWorkManagerType = NetworkManager()
  lazy var loginService: LoginServiceType = LoginService(provider: self)
}
