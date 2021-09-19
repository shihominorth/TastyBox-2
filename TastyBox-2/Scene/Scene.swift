//
//  LoginScene.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import Foundation

enum LoadingScene {
    case loading(LoadingVM), tutorial(TutorialVM)
}

enum LoginScene {
    case main(LoginMainVM), resetPassword(ResetPasswordVM), emailVerify(RegisterEmailVM), setPassword(SetPasswordVM), profileRegister(RegisterMyInfoProfileVM), about(AboutViewModel), tutorial(TutorialVM)
}

enum MainScene {
    case discovery(DiscoveryVM)
}
