//
//  Scene+ViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit
import Photos
import PhotosUI

extension Scene {
    
    func viewController() -> UIViewController {

        let storyboard = UIStoryboard(name: "CreateRecipe", bundle: nil)

        switch self {
        case .createReceipeScene(scene: .selectGenre(let viewModel)):
           
            let nc = storyboard.instantiateViewController(withIdentifier: "selectGenreNC") as! UINavigationController
            
            var vc = nc.viewControllers.first as? SelectGenresViewController
            
            vc?.bindViewModel(to: viewModel)
            
            return nc

        case .createReceipeScene(scene: .createRecipe(let viewModel)):
            var vc = storyboard.instantiateViewController(withIdentifier: "createRecipe") as! CreateRecipeViewController
            
            
            vc.bindViewModel(to: viewModel)
            
            return vc
        }
        
        
    }
    
//    func getViewController(scene: Scene, viewModel: ViewModelBase) -> UIViewController {
//        
//        var result: UIViewController!
//        
//        switch scene {
//        case .createScene:
//            
//            var viewcontroller: UIViewController? {
//                
//                if let viewModel = viewModel as? SelectGenresVM {
//                    return CreateRecipeScene.selectGenre(viewModel).viewController()
//                }
//                else if let viewModel = viewModel as? CreateRecipeVM {
//                    return CreateRecipeScene.createRecipe(viewModel).viewController()
//                }
//              
//                return nil
//            }
//            
//            result = viewcontroller
//            
//        default:
//            break
//        }
//        
//        
//        return result
//        
//    }
}

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


extension CreateRecipeScene {
    
    func viewController() -> UIViewController {

        let storyboard = UIStoryboard(name: "CreateRecipe", bundle: nil)
        
        switch self {
        case .createRecipe(let viewModel):

            var vc = storyboard.instantiateViewController(withIdentifier: "createRecipe") as! CreateRecipeViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .selectGenre(let viewModel):
           
            let nc = storyboard.instantiateViewController(withIdentifier: "selectGenreNC") as! UINavigationController

//            var vc = storyboard.instantiateViewController(withIdentifier: "selectGenre") as! SelectGenresViewController
//
//            vc.bindViewModel(to: viewModel)
            
            return nc
        }
    }
}

extension ImagePickScene {
    
    func viewController() -> PHPickerViewController {
        
        switch self {
        case .photo:
            
            var photoConfigPHPickerConfiguration: PHPickerConfiguration {

                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.selectionLimit = 1
                config.filter = PHPickerFilter.any(of: [.images, .livePhotos])
                
                
                return config
            }
            
            let vc = PHPickerViewController(configuration: photoConfigPHPickerConfiguration)
            
            return vc
            
        case .video:
            
            var videoConfigPHPickerConfiguration: PHPickerConfiguration {

                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.selectionLimit = 1
                config.filter = .videos
                config.preferredAssetRepresentationMode = .current
               
               return config
           }
            
            let vc = PHPickerViewController(configuration: videoConfigPHPickerConfiguration)
            
            return vc
            
        }
    }
}

extension VideoScene {
    
    func viewController() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: nil)
        
        switch self {
        case .player(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "uploadingVideoVC") as! UploadingVideoViewController
            vc.bindViewModel(to: viewModel)
            
            return vc
    
        }
        
    }
}
