//
//  LoginScene.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import Foundation

enum Scene {
//    case loadingScene, loginScene, mainScene, ingredientScene, createScene, imageScene, videoScene
    enum createRecipeScene {
        case createRecipe(CreateRecipeVM), selectGenre(SelectGenresVM)
    }
   
    case createReceipeScene(scene: createRecipeScene)
}

enum LoadingScene {
    case loading(LoadingVM), tutorial(TutorialVM)
}

enum LoginScene {
    case main(LoginMainVM), resetPassword(ResetPasswordVM), emailVerify(RegisterEmailVM), setPassword(SetPasswordVM), profileRegister(RegisterMyInfoProfileVM), about(AboutViewModel), tutorial(TutorialVM)
}

enum MainScene {
    case discovery(DiscoveryVM)
}

enum IngredientScene {
    case refrigerator(RefrigeratorVM), editRefrigerator(EditItemRefrigeratorVM), shoppinglist(ShoppinglistVM), editShoppinglist(EditShoppinglistVM)
}


enum CreateRecipeScene {
    case createRecipe(CreateRecipeVM), selectGenre(SelectGenresVM)
}

enum ImagePickScene {
    case photo, video
}

enum VideoScene {
    case player(UploadingVideoVM)
}
