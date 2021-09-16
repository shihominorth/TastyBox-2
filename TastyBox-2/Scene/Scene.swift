//
//  LoginScene.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import Foundation

enum LoginScene {
    case main(LoginMainVM), resetPassword(ResetPasswordVM), emailVerify(RegisterEmailVM), setPassword(SetPasswordVM), profileRegister(RegisterMyInfoProfileVM), about(AboutViewModel)
}

enum MainScene {
    case discovery(DiscoveryVM)
}
