//
//  BaseService.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

class BaseService {
  unowned let provider: ServiceProviderType
  
  init(provider: ServiceProviderType) {
    self.provider = provider
  }
}
