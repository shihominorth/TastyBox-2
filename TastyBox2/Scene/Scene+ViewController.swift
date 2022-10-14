//
//  Scene+ViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import UIKit
import Photos
import PhotosUI
import SafariServices

extension Scene {
    
    func viewController() -> UIViewController {

        switch self {
            
        case let .loadingScene(scene):
            
            return generateViewController(scene: scene)
          
        case let .loginScene(scene):
            
            return generateViewController(loginScene: scene)
            
        case let .discovery(scene):
            
            return generateViewController(discoveryScene: scene)
            
        case let .webSite(scene):
            
            return generateViewController(webSiteScene: scene)
            
        case let .ingredient(scene):
            
            return generateViewController(scene: scene)
            
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

extension Scene {
    
    
    func generateViewController(scene: LoadingScene) -> UIViewController {
        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
        
        switch scene {
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
    
    func generateViewController(loginScene scene: LoginScene) -> UIViewController {
      
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let aboutStoryBoard =  UIStoryboard(name: "About", bundle: nil)
        let tutorialStoryboard = UIStoryboard(name: "Tutorial", bundle: nil)
        
        switch scene {
        
        case .main(let viewModel):
        
            let nc = storyboard.instantiateViewController(withIdentifier: "loginMainNC")
            var vc = nc.children.first as! LoginMainPageViewController
            
            vc.bindViewModel(to: viewModel)
            
            return nc
            
        case .resetPassword(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "resetPassword") as! ResetPasswordViewController
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .emailVerify(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "EmailRegister") as! EmailLinkAuthenticationViewController
            
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
            let tabBarcontroller = storyboard.instantiateInitialViewController() as! MainTabViewController
            
            let mainNavigationController = storyboard.instantiateViewController(withIdentifier: "MainNC") as! UINavigationController
            var dicoveryViewController = mainNavigationController.viewControllers.first as! DiscoveryViewController
            dicoveryViewController.bindViewModel(to: viewModel)
            
            let postNavigationController = storyboard.instantiateViewController(withIdentifier: "PostNC") as! UINavigationController
            
            let searchNavigationController = storyboard.instantiateViewController(withIdentifier: "searchNC") as! UINavigationController

            
            tabBarcontroller.viewControllers = [mainNavigationController, postNavigationController, searchNavigationController]
            
            return tabBarcontroller
        }
        
    }
    
    func generateViewController(webSiteScene scene: WebSiteScene) -> UIViewController {
        
        switch scene {
            
        case .termsOfUseAndPrivacyPolicy:
            
            let url = URL(string: "https://tastybox2.weebly.com/privacy-policy-and-term-of-use.html")!
            
            let vc = SFSafariViewController(url: url)
            
            return vc
            
        case .contact:
            
            let url = URL(string: "https://tastybox2.weebly.com/contact.html")!
            
            let vc = SFSafariViewController(url: url)
            
            return vc
            
        }
    }
    
    func generateViewController(scene: IngredientScene) -> UIViewController {

        let storyboard = UIStoryboard(name: "Ingredient", bundle: nil)
        
        switch scene {
        
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
    
    func generateViewController(createRecipeScene scene: CreateRecipeScene) -> UIViewController {

        let storyboard = UIStoryboard(name: "CreateRecipe", bundle: nil)
        
        switch scene {
        
        case .createRecipe(let viewModel):
            
//            var vc = storyboard.instantiateViewController(withIdentifier: "createRecipe") as! CreateRecipeViewController
            let nc = storyboard.instantiateViewController(withIdentifier: "createRecipeNC") as! UINavigationController
            var vc = nc.viewControllers.first as! CreateRecipeViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
//            return nc
            
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
        case .myProfile(let viewModel):
           
            var vc = storyboard.instantiateViewController(withIdentifier: "myProfile") as! MyProfileViewController
            vc.bindViewModel(to: viewModel)
            
            return vc
       
        case .profile(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .myRelatedUsers(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "myRelatedUsersVC") as! MyRelatedUsersViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .relatedUsers(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "relatedUsersVC") as! RelatedUsersViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .manageRelatedUser(let viewModel):
            
            var vc = storyboard.instantiateViewController(withIdentifier: "manageRelatedUserVC") as! ManageRelatedUserViewController
            
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
        
        let storyBoard = UIStoryboard(name: "DigitalContents", bundle: nil)
        
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
            
            let nc = storyBoard.instantiateViewController(withIdentifier: "selectDigitalContentsNC") as! UINavigationController
////
            var vc = nc.topViewController as! SelectDigitalContentsViewController
            
//            var vc = storyBoard.instantiateViewController(withIdentifier: "selectDegitalContentsVC") as! SelectDigitalContentsViewController
            
            vc.bindViewModel(to: viewModel)
            
//            return vc
            return nc
            
        case .selectedImage(let viewModel):
            
            var vc = storyBoard.instantiateViewController(withIdentifier: "selectedImageVC") as! SelectedImageViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .selectedVideo(let viewModel):
            
            var vc = storyBoard.instantiateViewController(withIdentifier: "selectedVideoVC") as! SelectedVideoViewController
            
            vc.bindViewModel(to: viewModel)
            
            return vc
            
        case .selectThumbnail(let viewModel):
            
            let nc = storyBoard.instantiateViewController(withIdentifier: "selectThumbnailNC") as! UINavigationController
            var vc = nc.viewControllers.first as! SelectThumbnailViewController
//            var vc = storyBoard.instantiateViewController(withIdentifier: "selectThumbnailVC") as! SelectThumbnailViewController
            
            
            vc.bindViewModel(to: viewModel)
            
            return nc
//            return vc
            
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
