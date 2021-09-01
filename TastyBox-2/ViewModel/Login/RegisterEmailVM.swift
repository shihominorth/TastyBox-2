//
//  RegisterEmailVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Foundation
import Firebase
import RxSwift
import Action

class RegisterEmailVM: ViewModelBase {
    
    
    let apiType: RegisterAccountProtocol.Type
    
    var isRegistered: Single<Bool>?
    
    let sceneCoodinator: SceneCoordinator
    
    init(apiType: RegisterAccountProtocol.Type = RegisterAccountDM.self, sceneCoodinator: SceneCoordinator) {
        self.apiType = apiType
        self.sceneCoodinator = sceneCoodinator

    }
    
    func registerEmail(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        
        isRegistered = self.apiType.registerEmail(email: email, password: password).asSingle()
        
    }
    
    func showTermsAndConditions() -> CocoaAction {
        
        return CocoaAction { task in
          let registerEmailVM = RegisterEmailVM()
          return self.sceneCoodinator
              .transition(to: LoginScene.emailVerify(registerEmailVM), type: .push)
            .asObservable()
              .map {_ in }
        }
    }
}
