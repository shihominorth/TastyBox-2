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
import CloudKit


final class LoginMainVM: ViewModelBase {
    
    private let sceneCoodinator: SceneCoordinator
    private let apiType: LoginMainProtocol.Type
    var user: FirebaseAuth.User?
    
    let isEnableLoginBtnSubject: BehaviorRelay<Bool>
    let emailSubject: BehaviorSubject<String>
    let passwordSubject: BehaviorSubject<String>
    
    let googleBtnTappedStream: PublishSubject<UIViewController>
    
    var googleLoginedStream: Observable<Firebase.User> {
        return googleLoginAction.elements
    }
    
    var googleLoginErrStream: Observable<Error> {
        return googleLoginAction.errors
            .flatMapLatest { actionErr -> Observable<Error> in
                
                if case .underlyingError(let err) = actionErr {
                    return .just(err)
                }
                else {
                    return .empty()
                }
                
            }
    }
    
    let loginedStream: PublishSubject<Firebase.User>
    let loginErrStream: PublishSubject<Error>
    
    var isRegisteredStream: Observable<Bool> {
        return isRegisteredMyInfoAction.elements
    }
    
    var isRegisteredErrStream: Observable<Error> {
       
        return isRegisteredMyInfoAction.errors
            .flatMapLatest { actionErr -> Observable<Error> in
                
                if case .underlyingError(let err) = actionErr {
                    return .just(err)
                }
                else {
                    return .empty()
                }
                
            }
    }
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.isEnableLoginBtnSubject = BehaviorRelay<Bool>(value: false)
        self.emailSubject = BehaviorSubject<String>(value: "")
        self.passwordSubject = BehaviorSubject<String>(value: "")
        self.googleBtnTappedStream = PublishSubject<UIViewController>()
        
        self.loginedStream = PublishSubject<Firebase.User>()
        self.loginErrStream = PublishSubject<Error>()
        
        super.init()
        
        
        self.googleBtnTappedStream
            .bind(to: googleLoginAction.inputs)
            .disposed(by: disposeBag)
        
        
        self.googleLoginedStream
            .bind(to: self.loginedStream)
            .disposed(by: disposeBag)
        
        self.googleLoginErrStream
            .bind(to: self.loginErrStream)
            .disposed(by: disposeBag)
        
        self.loginedStream
            .do(onNext: { user in
                
                self.user = user
                
            })
            .bind(to: isRegisteredMyInfoAction.inputs)
            .disposed(by: disposeBag)
        
        
        self.isRegisteredStream
            .subscribe(onNext: { [unowned self] isFirst in
                
                self.goToNext(isFirst: isFirst)
                
            })
            .disposed(by: disposeBag)
        
        self.isRegisteredErrStream
            .subscribe(onNext: { err in
                
                print(err)
                
                self.goToNext(isFirst: false)
                
            })
            .disposed(by: self.disposeBag)
        

    }
    
    private lazy var isRegisteredMyInfoAction: Action<Firebase.User, Bool> = { this in
        
        return Action { user in
            
            return self.apiType.isRegisteredMyInfo
            
        }
        
    }(self)
    
    
    //    Singleは一回のみElementかErrorを送信することが保証されているObservableです。
    //    一回イベントを送信すると、disposeされるようになってます。
 
    func isRegisteredMyInfo(user: Firebase.User) -> Observable<Bool> {
       

       return self.apiType.isRegisteredMyInfo
//            .catch({ err in
//            
//                err.handleAuthenticationError()?.generateErrAlert()
//                
//                return .empty()
//            
//            })
            
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
        self.sceneCoodinator.transition(to: scene, type: .push)
//        }
       
    }
    
    private func goToMain(user: Firebase.User) {

        let vm = DiscoveryVM(sceneCoodinator: self.sceneCoodinator, user: user)
        let scene: Scene = .discovery(scene: .main(vm))
        self.sceneCoodinator.transition(to: scene, type: .root)

    }
    
    private lazy var googleLoginAction: Action<UIViewController, Firebase.User> = { this in
        
        return Action { vc in
                
            return this.apiType.loginWithGoogle(viewController: vc)
            
        }
        
    }(self)
    
    
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
                .transition(to: scene, type: .push)
                .asObservable()
                //Cannot convert return expression of type 'Observable<Never>' to return type 'Observable<Void>'
                .map { _ in }  // 上記のエラーがこれで解決する
            
        }
    }
    
    func registerEmail() -> CocoaAction {
        
        return CocoaAction { task in
            
            let vm = EmailLinkAuthenticationVM(sceneCoordinator: self.sceneCoodinator)
            let scene: Scene = .loginScene(scene: .emailVerify(vm))
           
            return self.sceneCoodinator
                .transition(to: scene, type: .push)
                .asObservable()
                .map {_ in }
        }
    }
    
    

    func toWebSite() {
        
        let scene: Scene = .webSite(scene: .termsOfUseAndPrivacyPolicy)
        
        self.sceneCoodinator.transition(to: scene, type: .web)
    }
    
}

