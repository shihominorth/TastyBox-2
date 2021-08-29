//
//  Scene+ViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit

extension LoginScene {
  func viewController() -> UIViewController {
    let storyboard = UIStoryboard(name: "Login", bundle: nil)
    
    switch self {
    
    case .main(let viewModel):
        let nc = storyboard.instantiateViewController(withIdentifier: "LoginMain") as! UINavigationController
        var vc = nc.viewControllers.first as! LoginMainPageViewController
        vc.bindViewModel(to: viewModel)
        return nc

    case .resetPassword(let viewModel):
        
        var vc = storyboard.instantiateViewController(withIdentifier: "resetPassword") as!  ResetPasswordViewController
        vc.bindViewModel(to: viewModel)
        
        return vc

    case .emailVerify(let viewModel):
        
        var vc = storyboard.instantiateViewController(withIdentifier: "EmailRegister") as! EmailRegisterViewController
        
        vc.bindViewModel(to: viewModel)
        
        return vc

    case .profileRegister(let viewModel):
        
        var vc = storyboard.instantiateViewController(withIdentifier: "FirstTimeProfile") as! FirstTimeUserProfileTableViewController
        vc.bindViewModel(to: viewModel)
        return vc
    }
  }
}
