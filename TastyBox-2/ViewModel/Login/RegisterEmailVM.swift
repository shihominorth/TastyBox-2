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
    
    let sceneCoordinator: SceneCoordinator
    
    init(apiType: RegisterAccountProtocol.Type = RegisterAccountDM.self, sceneCoordinator: SceneCoordinator) {
        self.apiType = apiType
        self.sceneCoordinator = sceneCoordinator

    }
    
    func registerEmail(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        
        isRegistered = self.apiType.registerEmail(email: email, password: password).asSingle()
        
    }
    
    func aboutAction() -> CocoaAction {
      return CocoaAction { _ in
        
        let viewModel = AboutViewModel(sceneCoodinator: self.sceneCoordinator, prevVC: .registerEmail, isAgreed: false)
        let viewController = LoginScene.about(viewModel).viewController()
        
            return self.sceneCoordinator
                .transition(to: viewController, type: .push)
              .asObservable()
              .map { _ in }
        }
        
    }
    
    lazy var sendEmailWithLink: Action<String, Swift.Never> = { this in
        
        return Action { email in
            
            print(email)
            
            return self.apiType.sendEmailWithLink(email: email)
                .catch { err in
                    
                    print(err)
                    return .empty()
                    
                }.asObservable()
        }
    }(self)
//    
//    func showTermsAndConditions() -> CocoaAction {
//        
//        return CocoaAction { task in
//          let registerEmailVM = RegisterEmailVM()
//            let viewController = LoginScene.emailVerify(registerEmailVM)
//          return self.sceneCoodinator
//              .transition(to: viewController, type: .push)
//            .asObservable()
//              .map {_ in }
//        }
//    }
}
