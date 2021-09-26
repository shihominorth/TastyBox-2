//
//  Scene+ViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit

extension LoadingScene {
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
        
        switch self {
        case .loading(let viewModel):
            
            let nc = storyboard.instantiateViewController(withIdentifier: "loadingNC") as! UINavigationController
            var vc = nc.viewControllers.first as! LoadingViewController
            vc.bindViewModel(to: viewModel)
            return nc
            
            
        case .tutorial(let viewModel):
            var vc = storyboard.instantiateViewController(withIdentifier: "tutorial") as! TutorialViewController
            vc.bindViewModel(to: viewModel)
            return vc
        }
    }
}

extension LoginScene {
   
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let aboutStoryBoard =  UIStoryboard(name: "About", bundle: nil)
        let tutorialStoryboard = UIStoryboard(name: "Tutorial", bundle: nil)
        
        switch self {
        
        case .main(let viewModel):
            //        let nc = storyboard.instantiateViewController(withIdentifier: "LoginMain") as! UINavigationController
            //        var vc = nc.viewControllers.first as! LoginMainPageViewController
            var vc = storyboard.instantiateViewController(identifier: "loginPage") as! LoginMainPageViewController
            
            vc.bindViewModel(to: viewModel)
            //        return nc
            
            return vc
            
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
            
        case .tutorial(let viewModel):
            var vc = tutorialStoryboard.instantiateViewController(withIdentifier: "tutorial") as! TutorialViewController
            vc.bindViewModel(to: viewModel)
            return vc
        }
    }
}


extension MainScene {
    
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //    let aboutStoryBoard =  UIStoryboard(name: "About", bundle: nil)
        
        switch self {
        
        case .discovery(let viewModel):
            let nc = storyboard.instantiateViewController(withIdentifier: "MainNC") as! UINavigationController
            var vc = nc.viewControllers.first as! DiscoveryViewController
            vc.bindViewModel(to: viewModel)
            return nc
            
        //    case .resetPassword(let viewModel):
        //
        //        var vc = storyboard.instantiateViewController(withIdentifier: "resetPassword") as!  ResetPasswordViewController
        //        vc.bindViewModel(to: viewModel)
        //
        //        return vc
        //
        //    case .emailVerify(let viewModel):
        //
        //        var vc = storyboard.instantiateViewController(withIdentifier: "EmailRegister") as! EmailRegisterViewController
        //
        //        vc.bindViewModel(to: viewModel)
        //
        //        return vc
        //
        //    case .setPassword(let viewModel):
        //
        //        let nc = storyboard.instantiateViewController(withIdentifier: "setPassword") as! UINavigationController
        //        var vc = nc.viewControllers.first as! SetPasswordViewController
        ////        var vc = storyboard.instantiateViewController(identifier: "setPassword") as! SetPasswordViewController
        //
        //        vc.bindViewModel(to: viewModel)
        //
        //        return nc
        //
        //
        //    case .profileRegister(let viewModel):
        //
        //        var vc = storyboard.instantiateViewController(withIdentifier: "FirstTimeProfile") as! RegisterMyInfoProfileTableViewController
        //        vc.bindViewModel(to: viewModel)
        //        return vc
        //
        //    case .about(let viewModel):
        //
        //        var vc =  aboutStoryBoard.instantiateViewController(withIdentifier: "about") as! AboutViewController
        //        vc.bindViewModel(to: viewModel)
        //        return vc
        
        }
    }
}

extension IngredientScene {
   
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Ingredient", bundle: nil)
        //    let aboutStoryBoard =  UIStoryboard(name: "About", bundle: nil)
        
        switch self {
        
        case .refrigerator(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "refrigerator") as! RefrigeratorViewController
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .editRefrigerator(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "editItemRefrigerator") as! EditItemRefrigeratorViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .shoppinglist(let viewModel):
            var vc = storyboard.instantiateViewController(withIdentifier: "shoppinglist") as! ShoppinglistViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .editShoppinglist(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "editItemShoppinglist") as! EditShoppingListViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
        }
    }
}
