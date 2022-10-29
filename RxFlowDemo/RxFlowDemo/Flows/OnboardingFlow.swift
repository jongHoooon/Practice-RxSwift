//
//  OnboardingFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-11.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import UIKit.UINavigationController
import RxFlow

class OnboardingFlow: Flow {
  var root: Presentable {
    return self.rootVIew
  }
}
