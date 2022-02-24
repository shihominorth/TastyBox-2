//
//  RegisterEmailVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Action
import Foundation
import Firebase
import RxSwift
import SCLAlertView

final class RegisterEmailVM: ViewModelBase {
    
    
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
            
            let vm = AboutViewModel(sceneCoodinator: self.sceneCoordinator, prevVC: .registerEmail, isAgreed: false)
            let scene: Scene = .loginScene(scene: .about(vm))
            
            return self.sceneCoordinator
                .transition(to: scene, type: .push)
                .asObservable()
                .map { _ in }
        }
        
    }
    
    lazy var sendEmailWithLink: Action<String, Void> = { this in
        
        return Action { email in
   
          return self.apiType.sendEmailWithLink(email: email)
                    .do(onNext: { isCompleted in
                       
                        SCLAlertView().showTitle(
                            "Sent Email Validation", // Title of view
                            subTitle: "Please Check your email and open the link.",
                            timeout: .none, // String of view
                            completeText: "OK", // Optional button value, default: ""
                            style: .success, // Styles - see below.
                            colorStyle: 0xA429FF,
                            colorTextButton: 0xFFFFFF
                        )
                        
                    }, onError: { err in
                        
                        guard let reason = err.handleAuthenticationError() else {
                            
                            SCLAlertView().showTitle(
                                "Error", // Title of view
                                subTitle: "You can't login.",
                                timeout: .none, // String of view
                                completeText: "Done", // Optional button value, default: ""
                                style: .error, // Styles - see below.
                                colorStyle: 0xA429FF,
                                colorTextButton: 0xFFFFFF
                            )
                            
                            return
                        }
                        
                        reason.showErrNotification()
                        
                    })
                        .map { _ in }
                
            
        }
        
    }(self)
    
    func toLoginMainAction() -> CocoaAction {
        return CocoaAction { this in
            
            let vm = LoginMainVM(sceneCoodinator: self.sceneCoordinator)
            let scene: Scene = .loginScene(scene: .main(vm))
            
            return self.sceneCoordinator.transition(to: scene, type: .modal(presentationStyle: nil, modalTransisionStyle: nil, hasNavigationController: false)).asObservable().map { _ in }
        }
    }
    
    func toSetPassword(email: String) {
        
        let vm = SetPasswordVM(email: email, apiType: self.apiType, sceneCoordinator: self.sceneCoordinator)
        let scene: Scene = .loginScene(scene: .setPassword(vm))
        self.sceneCoordinator.transition(to: scene, type: .push)
    }
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
