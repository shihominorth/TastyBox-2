//
//  LoginViewModel.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Argus Chen. All rights reserved.
//
import Action
import AuthenticationServices
import CryptoKit
import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import RxSwift
import RxRelay
import SCLAlertView


class LoginMainVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let apiType: LoginMainProtocol.Type
    var user: FirebaseAuth.User?
    let isEnableLoginBtnSubject: BehaviorRelay<Bool>
    let emailSubject: BehaviorSubject<String>
    let passwordSubject: BehaviorSubject<String>
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.isEnableLoginBtnSubject = BehaviorRelay<Bool>(value: false)
        self.emailSubject = BehaviorSubject<String>(value: "")
        self.passwordSubject = BehaviorSubject<String>(value: "")

    }
    
    
    //    Singleは一回のみElementかErrorを送信することが保証されているObservableです。
    //    一回イベントを送信すると、disposeされるようになってます。
 
    func isRegisteredMyInfo(user: Firebase.User) -> Observable<Bool> {
       

       return self.apiType.isRegisterMyInfo
            .catch({ err in
            
                err.handleAuthenticationError()?.generateErrAlert()
                
                return .empty()
            
            })
            
    }
    
    func goToNext(isFirst: Bool) {
        
        if let user = user {

            if isFirst {
                self.goToRegisterMyInfo(user: user)
            }
            else {
                self.goToMain(user: user)
            }
        }
  
    }
     
    
    private func goToRegisterMyInfo(user: Firebase.User) {
        
//        if let user = self.user {
        let vm = RegisterMyInfoProfileVM(sceneCoodinator: sceneCoodinator, user: user)
        let scene: Scene = .loginScene(scene: .profileRegister(vm))
        self.sceneCoodinator.modalTransition(to: scene, type: .push)
//        }
       
    }
    
    private func goToMain(user: Firebase.User) {

        let vm = DiscoveryVM(sceneCoodinator: self.sceneCoodinator, user: user)
        let scene: Scene = .discovery(scene: .main(vm))
        self.sceneCoodinator.modalTransition(to: scene, type: .root)

    }
    
    
    func googleLogin(presenting vc: UIViewController) -> Observable<Event<Firebase.User>> {
   
        return self.apiType.loginWithGoogle(viewController: vc)
            .do(onNext: {  user in
                
                self.user = user
            
            })
                .materialize()

    }
    
    
    func appleLogin(presenting: UIViewController) -> Observable<Event<Firebase.User>> {

        return self.apiType.startSignInWithAppleFlow(authorizationController: presenting)
            .do(onNext: {  user in
                
                self.user = user
            
            }).materialize()
   
    }
    
    
    func faceBookLogin(presenting: UIViewController, button: FBLoginButton) -> Observable<Event<Firebase.User>> {

        return button.rx.signIn
            .do(onNext: { user in
            
            self.user = user
        
            }).materialize()

    }
    
    func checkIsEmptyTxtFields(isEnabled: Bool) -> Observable<(String, String)> {
        
        if isEnabled {
            
            return .combineLatest(emailSubject, passwordSubject) { email, password in
                
                return (email, password)
                
            }
            
        }
        else {
            
            let notification = Notification(reason: "Email or password is empty", solution: "You need to fill both.")
            
            notification.showErrNotification()
            
            return .empty()
        }
        
    }
    
    func login(email: String?, password: String?) -> Observable<Event<Firebase.User>> {
        
        return self.apiType.login(email: email, password: password)
            .map {
                $0.user
            }
            .do(onNext: { user in
            
                self.user = user
            
            }).materialize()
                
    }

    
    func logined(user: Firebase.User) -> Observable<Firebase.User> {
        
        return self.apiType.logined(user: user)
        
    }
    
    func resetPassword() -> CocoaAction {
        return CocoaAction { _ in
            
            let vm = ResetPasswordVM(coordinator: self.sceneCoodinator)
            let scene:Scene = .loginScene(scene: .resetPassword(vm))
            
            return self.sceneCoodinator
                .modalTransition(to: scene, type: .push)
                .asObservable()
                //Cannot convert return expression of type 'Observable<Never>' to return type 'Observable<Void>'
                .map { _ in }  // 上記のエラーがこれで解決する
            
        }
    }
    
    func registerEmail() -> CocoaAction {
        
        return CocoaAction { task in
            
            let vm = RegisterEmailVM(sceneCoordinator: self.sceneCoodinator)
            let scene: Scene = .loginScene(scene: .emailVerify(vm))
           
            return self.sceneCoodinator
                .modalTransition(to: scene, type: .push)
                .asObservable()
                .map {_ in }
        }
    }
    
    

}

