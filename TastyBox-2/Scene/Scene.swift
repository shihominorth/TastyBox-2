//
//  LoginScene.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import Foundation
import RxSwift

enum Scene {
    
    enum LoginScene {
        case main(LoginMainVM), resetPassword(ResetPasswordVM), emailVerify(RegisterEmailVM), setPassword(SetPasswordVM), profileRegister(RegisterMyInfoProfileVM), about(AboutViewModel), tutorial(TutorialVM)
    }
    
    enum DiscoveryScene {
        case main(DiscoveryVM)
    }

    enum CreateRecipeScene {
        case createRecipe(CreateRecipeVM), selectGenre(SelectGenresVM), uploadingVideo(UploadingVideoVM),  checkRecipe(CheckRecipeVM), publishRecipe(PublishRecipeVM)
    }
    
    enum ProfileScene {
        case myProfile(MyProfileVM), profile(ProfileVM), myRelatedUsers(MyRelatedUsersVM), relatedUsers(RelatedUsersVM), manageRelatedUser(ManageRelatedUserVM)
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
    
   
    case loginScene(scene: LoginScene), discovery(scene: DiscoveryScene), createReceipeScene(scene: CreateRecipeScene), profileScene(scene: ProfileScene), recipeScene(scene: RecipeDetailScene), reportScene(scene: ReportScene), digitalContentsPickerScene(scene: DigitalContentsPickerScene)
    
}

enum LoadingScene {
    case loading(LoadingVM), tutorial(TutorialVM)
}

enum LoginScene {
    case main(LoginMainVM), resetPassword(ResetPasswordVM), emailVerify(RegisterEmailVM), setPassword(SetPasswordVM), profileRegister(RegisterMyInfoProfileVM), about(AboutViewModel), tutorial(TutorialVM)
}

enum DiscoveryScene {
    case discovery(DiscoveryVM) //, ranking(RankingVM)
}

enum MainScene {
    case timeline(TimelineVM), ingredients(IngredientsVM), ranking(RankingVM)
}

enum IngredientScene {
    case refrigerator(RefrigeratorVM), editRefrigerator(EditItemRefrigeratorVM), shoppinglist(ShoppinglistVM), editShoppinglist(EditShoppinglistVM)
}


//enum CreateRecipeScene {
//    case createRecipe(CreateRecipeVM), selectGenre(SelectGenresVM), checkRecipe(CheckRecipeVM)
//}

enum ImagePickScene {
    case photo, video
}

enum VideoScene {
    case player(UploadingVideoVM)
}
