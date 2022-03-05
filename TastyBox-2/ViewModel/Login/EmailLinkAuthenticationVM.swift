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

final class EmailLinkAuthenticationVM: ViewModelBase {
    
    
    private let apiType: RegisterAccountProtocol.Type
    
    private let sceneCoordinator: SceneCoordinator
    
    var isRegistered: Single<Bool>? // singleだとcompletedが流れて
    
    let emailSubject: PublishSubject<String>
    let sendLinkTrigger: PublishSubject<Void>
   
    var successStream: Observable<Void> {
        return sendEmailWithLink.elements
    }
    
    var errorStream: Observable<Error> {
       
        return sendEmailWithLink.errors
            .flatMapLatest { actionErr -> Observable<Error> in
                
                if case .underlyingError(let err) = actionErr {
                    return .just(err)
                }
                
                return .empty()
            }
            
    }
    
    init(apiType: RegisterAccountProtocol.Type = RegisterAccountDM.self, sceneCoordinator: SceneCoordinator) {
        
        self.apiType = apiType
        self.sceneCoordinator = sceneCoordinator
        self.emailSubject = PublishSubject<String>()
        self.sendLinkTrigger = PublishSubject<Void>()
        
        super.init()
        
        self.sendLinkTrigger
            .withLatestFrom(self.emailSubject)
            .bind(to: sendEmailWithLink.inputs)
            .disposed(by: disposeBag)
        
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
    
   private lazy var sendEmailWithLink: Action<String, Void> = { this in
        
        return Action { email in
   
          return this.apiType.sendEmailWithLink(email: email)
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
