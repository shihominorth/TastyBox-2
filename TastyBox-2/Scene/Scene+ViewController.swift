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

        switch self {
          
        case let .loginScene(scene):
            
            return generateViewController(loginScene: scene)
            
        case let .discovery(scene):
            
            return generateViewController(discoveryScene: scene)
            
        case let .createReceipeScene(scene):
            
            return generateViewController(createRecipeScene: scene)
            
        case let .profileScene(scene):

            return generateViewController(profileScene: scene)
            
        case let .recipeScene(scene):
  
            return generateViewController(recipeScene: scene)
            
        case let .reportScene(scene):
            
            return generateViewController(reportScene: scene)
            
        case let .digitalContentsPickerScene(scene):
            
            return generateViewController(digitalContentsPickerScene: scene)
        }
        
        
    }
}

extension MainScene {
    
    func viewController() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        switch self {
        case .timeline(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "timelineVC") as! TimelineViewController
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .ranking(let viewModel):
            var vc = storyboard.instantiateViewController(withIdentifier: "rankingVC") as! RankingViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .ingredients(let viewModel):
           
            var vc = storyboard.instantiateViewController(withIdentifier: "ingredientsVC") as! IngredientsViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
        }
    }
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


extension DiscoveryScene {
    
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


extension Scene {
    
    func generateViewController(loginScene scene: LoginScene) -> UIViewController {
      
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let aboutStoryBoard =  UIStoryboard(name: "About", bundle: nil)
        let tutorialStoryboard = UIStoryboard(name: "Tutorial", bundle: nil)
        
        switch scene {
        
        case .main(let viewModel):
        
            var vc = storyboard.instantiateViewController(identifier: "loginPage") as! LoginMainPageViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .resetPassword(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "resetPassword") as! ResetPasswordViewController
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
    
    func generateViewController(discoveryScene scene: DiscoveryScene) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //    let aboutStoryBoard =  UIStoryboard(name: "About", bundle: nil)
        
        switch scene {
            
        case .main(let viewModel):
            let nc = storyboard.instantiateViewController(withIdentifier: "MainNC") as! UINavigationController
            var vc = nc.viewControllers.first as! DiscoveryViewController
            vc.bindViewModel(to: viewModel)
            return nc
        }
        
    }
    
    func generateViewController(createRecipeScene scene: CreateRecipeScene) -> UIViewController {

        let storyboard = UIStoryboard(name: "CreateRecipe", bundle: nil)
        
        switch scene {
        
        case .createRecipe(let viewModel):

//            var vc = storyboard.instantiateViewController(withIdentifier: "createRecipe") as! CreateRecipeViewController
            let nc = storyboard.instantiateViewController(withIdentifier: "createRecipeNC") as! UINavigationController
            var vc = nc.viewControllers.first as! CreateRecipeViewController
            
            vc.bindViewModel(to: viewModel)
            
//            return vc
            return nc
            
        case .selectGenre(let viewModel):
           
            let nc = storyboard.instantiateViewController(withIdentifier: "selectGenreNC") as! UINavigationController

//            var vc = nc.viewControllers.first as? SelectGenresViewController
            var vc = nc.viewControllers.first as? SearchGenresViewController

//            var vc = storyboard.instantiateViewController(withIdentifier: "selectGenre") as! SelectGenresViewController

            vc?.bindViewModel(to: viewModel)
            
            return nc
            
        case .uploadingVideo(let viewModel):
            
            var vc = UIStoryboard(name: "VideoPlayer", bundle: nil).instantiateViewController(withIdentifier: "uploadingVideoVC") as! UploadingVideoViewController
            vc.bindViewModel(to: viewModel)
            
            return vc
            
            
        case .checkRecipe(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "checkRecipeVC") as! CheckCreatedRecipeViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .publishRecipe(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "PublishRecipeVC") as! PublishRecipeOptionsViewController

            vc.bindViewModel(to: viewModel)
            
            return vc
        }
    }
    
    func generateViewController(profileScene scene: ProfileScene) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)

        switch scene {
        case .myprofile(let viewModel):
           
            var vc = storyboard.instantiateViewController(withIdentifier: "myProfile") as! MyProfileViewController
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        }
        
    }
    
    func generateViewController(recipeScene scene: RecipeDetailScene) -> UIViewController {
        
        let storyBoard = UIStoryboard(name: "RecipeDetail", bundle: nil)
        
        
        switch scene {
        case .recipe(let viewModel):
            
            var vc = storyBoard.instantiateViewController(withIdentifier: "recipeDetail") as! RecipeViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        }
    }
    
    func generateViewController(reportScene scene: ReportScene) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Report", bundle: nil)
        
        switch scene {
        case .report(let viewModel):
        
            var vc = storyBoard.instantiateViewController(withIdentifier: "reportOptionsVC") as! ReportViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        }
    }
    
    func generateViewController(digitalContentsPickerScene scene: DigitalContentsPickerScene) -> UIViewController {
        
        switch scene {
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
            
        case .camera:
            
            // 写真を選ぶビュー
            let pickerVC = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerVC.sourceType = .camera
            
            return pickerVC
            
        case .selectDigitalContents(let viewModel):
            
            let nc = UIStoryboard(name: "CreateRecipe", bundle: nil).instantiateViewController(withIdentifier: "selectDigitalContentsNC") as! UINavigationController
            
            var vc = nc.viewControllers.first(where: { $0 is SelectDigitalContentsViewController}) as! SelectDigitalContentsViewController
            
            vc.bindViewModel(to: viewModel)
            
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
                
                let photoLibrary = PHPhotoLibrary.shared()
                var config = PHPickerConfiguration(photoLibrary: photoLibrary)
//                var config = PHPickerConfiguration(photoLibrary: .shared())
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

extension Scene {
    
    
    
}
