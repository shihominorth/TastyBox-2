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
    let aboutStoryBoard =  UIStoryboard(name: "About", bundle: nil)
    
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
        
    case .setPassword(let viewModel):

        let nc = storyboard.instantiateViewController(withIdentifier: "setPassword") as! UINavigationController
        var vc = nc.viewControllers.first as! SetPasswordViewController
//        var vc = storyboard.instantiateViewController(identifier: "setPassword") as! SetPasswordViewController
        
        vc.bindViewModel(to: viewModel)
        
        return nc
        

    case .profileRegister(let viewModel):
        
        var vc = storyboard.instantiateViewController(withIdentifier: "FirstTimeProfile") as! RegisterMyInfoProfileTableViewController
        vc.bindViewModel(to: viewModel)
        return vc
        
    case .about(let viewModel):
        
        var vc =  aboutStoryBoard.instantiateViewController(withIdentifier: "about") as! AboutViewController
        vc.bindViewModel(to: viewModel)
        return vc
        
    }
  }
}
