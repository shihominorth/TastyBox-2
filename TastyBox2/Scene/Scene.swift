//
//  LoginScene.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import Foundation
import RxSwift

enum Scene {
    enum LoadingScene {
        case loading(LoadingVM), tutorial(TutorialVM)
    }

    enum LoginScene {
        case main(LoginMainVM), resetPassword(ResetPasswordVM), emailVerify(EmailLinkAuthenticationVM), setPassword(SetPasswordVM), profileRegister(RegisterMyInfoProfileVM), about(AboutViewModel), tutorial(TutorialVM)
    }
    
    enum MainScene {
        case main(MainTabBarViewModelLike)
    }
    
    enum DiscoveryScene {
        case discovery(DiscoveryViewModelLike)
    }
    
    enum SearchScene {
        case main
    }
    
    enum WebSiteScene {
        case termsOfUseAndPrivacyPolicy, contact
    }
    
    enum IngredientScene {
        case refrigerator(RefrigeratorVM), editRefrigerator(EditItemRefrigeratorVM), shoppinglist(ShoppinglistVM), editShoppinglist(EditShoppinglistVM)
    }

    enum CreateRecipeScene {
        case createRecipe(CreateRecipeVM), selectGenre(SelectGenresVM), uploadingVideo(UploadingVideoVM),  checkRecipe(CheckRecipeVM), publishRecipe(PublishRecipeVM)
    }
    
    enum ProfileScene {
        case myProfile(MyProfileVM), profile(ProfileVM), myRelatedUsers(MyRelatedUsersVM), relatedUsers(RelatedUsersVM), manageRelatedUser(ManageMyRelatedUserVM)
    }
    
    enum RecipeDetailScene {
        case recipe(RecipeVM)
    }
    
    enum ReportScene {
        case report(ReportVM)
    }
    
    enum DigitalContentsPickerScene {
        case video, photo, camera, selectDigitalContents(SelectDigitalContentsVM), selectedImage(SelectedImageVM), selectedVideo(SelectedVideoVM), selectThumbnail(SelectThumbnailVM)
    }
    
   
    case loadingScene(scene: LoadingScene), loginScene(scene: LoginScene), main(scene: MainScene), discovery(scene: DiscoveryScene), search(scene: SearchScene), webSite(scene: WebSiteScene), ingredient(scene: IngredientScene), createReceipeScene(scene: CreateRecipeScene), profileScene(scene: ProfileScene), recipeScene(scene: RecipeDetailScene), reportScene(scene: ReportScene), digitalContentsPickerScene(scene: DigitalContentsPickerScene)
    
}

enum MainScene {
    case timeline(TimelineViewModel), ingredients(IngredientsViewModel), ranking(RankingViewModel)
}


enum ImagePickScene {
    case photo, video
}

enum VideoScene {
    case player(UploadingVideoVM)
}
