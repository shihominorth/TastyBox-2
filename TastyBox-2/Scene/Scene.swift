//
//  LoginScene.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import Foundation

enum Scene {

    enum CreateRecipeScene {
        case createRecipe(CreateRecipeVM), selectGenre(SelectGenresVM), checkRecipe(CheckRecipeVM), publishRecipe(PublishRecipeVM)
    }
    
    enum ProfileScene {
        case myprofile(MyProfileVM)
    }
    
    enum RecipeDetailScene {
        case recipe(RecipeVM)
    }
   
    case createReceipeScene(scene: CreateRecipeScene), profileScene(scene: ProfileScene), recipeScene(scene: RecipeDetailScene)
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
    case ranking(RankingVM)
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
