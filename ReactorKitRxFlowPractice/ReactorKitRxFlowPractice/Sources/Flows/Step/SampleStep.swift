//
//  SampleStep.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import RxFlow

enum SampleStep: Step {
    // Global
    case alert(message: String)
    case dismiss
    
    // Login
    case loginIsRequired
    case loginIsCompleted
    
    // Main
    case mainTabBarIsRequired
    
    // Home
    case homeIsRequired
    case homeItemIsPicked(withID: String)
    
    // Middle
    case middleIsRequired
    case middleIsRequiredAgain
    case middleDetailIsRequired
    
    // Setting
    case settingIsRequired
    case settingAndAlertIsRequired(message: String)
}
