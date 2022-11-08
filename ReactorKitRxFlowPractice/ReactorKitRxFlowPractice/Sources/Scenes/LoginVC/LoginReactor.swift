//
//  LoginReactor.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import Foundation

import RxFlow
import RxCocoa
import ReactorKit

final class LoginReactor: Reactor, Stepper {
  
  // MARK: - Stepper
  
  var steps: PublishRelay<Step> = .init()
  
  // MARK: - Event
  
  enum Action {
      case loginButtonDidTap
  }
  
  enum Mutation {
  }
  
  struct State {
  }
  
  // MARK: - Properties
  
  let initialState: State
  let provider: ServiceProviderType
  
  init(provider: ServiceProviderType) {
    self.provider = provider
    initialState = State()
  }
  
  // MARK: - Mutation
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .loginButtonDidTap:
      provider.loginService.setUserLogin()
      
      steps.accept(SampleStep.loginIsCompleted)
      return .empty()
    }
  }
  
  // MARK: - Reduce
  
  func reduce(state: State, mutation: Mutation) -> State {
    
  }
}
