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
    var err = NSError()
    
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        
        
    }
    
    
    //    Singleは一回のみElementかErrorを送信することが保証されているObservableです。
    //    一回イベントを送信すると、disposeされるようになってます。
    var isLogined: Observable<Bool> {
        
        return Observable.create { observable in
            
            if (Auth.auth().currentUser?.uid) != nil {
                
                self.user = Auth.auth().currentUser

                observable.onNext(true)
                
            } else {
                observable.onNext(false)
            }
            
            return Disposables.create()
        }
        
    }
    
 
    private func isRegisteredmyInfo() {
       
        
       let _ = self.apiType.isRegisterMyInfo.subscribe(onSuccess: { isFirst in
            
            if isFirst {
                self.goToRegisterMyInfo()
            } else {
                self.goToMain()
            }
            
        }, onFailure: { err in
            
            guard let reason = self.err.handleAuthenticationError() else { return }
            SCLAlertView().showTitle(
                reason.reason, // Title of view
                subTitle: reason.solution,
                timeout: .none, // String of view
                completeText: "Done", // Optional button value, default: ""
                style: .error, // Styles - see below.
                colorStyle: 0xA429FF,
                colorTextButton: 0xFFFFFF
            )
            
        })
    }
     
    
    fileprivate func goToRegisterMyInfo() {
        
        if let user = self.user {
            let vm = RegisterMyInfoProfileVM(sceneCoodinator: sceneCoodinator, user: user)
            let vc = LoginScene.profileRegister(vm).viewController()
            self.sceneCoodinator.transition(to: vc, type: .push)
        }
       
    }
    
    fileprivate func goToMain() {
        if let user = self.user {
            let vm = DiscoveryVM(sceneCoodinator: self.sceneCoodinator, user: user)
            let vc = MainScene.discovery(vm).viewController()
            self.sceneCoodinator.transition(to: vc, type: .modal)
        }
    }
    
    
    func googleLogin(presenting vc: UIViewController) -> Observable<FirebaseAuth.User> {
        
        return Observable.create { observable in
            
            self.apiType.loginWithGoogle(viewController: vc).subscribe { event in
                
                switch event {
                case .failure(let err as NSError):
                    
                    self.err = err
                    
                    guard let reason = self.err.handleAuthenticationError() else { return }
                    
                    SCLAlertView().showTitle(
                        reason.reason, // Title of view
                        subTitle: reason.solution,
                        timeout: .none, // String of view
                        completeText: "Done", // Optional button value, default: ""
                        style: .error, // Styles - see below.
                        colorStyle: 0xA429FF,
                        colorTextButton: 0xFFFFFF
                    )
                    
                case .success(let user):
                    
                    self.user = user
                    
                    self.isRegisteredmyInfo()
                    observable.onNext(user)
                }
                
                
            }
        }
    }
    
    func appleLogin(presenting: UIViewController) -> Observable<FirebaseAuth.User> {
        
        return Observable.create { observer in
            _ =
                self.apiType.startSignInWithAppleFlow(authorizationController: presenting)
                .subscribe(onNext: { controller in
                    
                    let _ =  controller.rx.signIn
                        .subscribe(onNext: { user in
                            
                            self.user = user
                            self.isRegisteredmyInfo()

                            observer.onNext(user)
                            
                        }, onError: { err in
                            
                            self.err = err as NSError
                            observer.onError(err)

                            guard let reason = self.err.handleAuthenticationError() else { return }
                            SCLAlertView().showTitle(
                                reason.reason, // Title of view
                                subTitle: reason.solution,
                                timeout: .none, // String of view
                                completeText: "Done", // Optional button value, default: ""
                                style: .error, // Styles - see below.
                                colorStyle: 0xA429FF,
                                colorTextButton: 0xFFFFFF
                            )
                            
                        })
                    
                },
                onError: { err in
                    self.err = err as NSError
                    observer.onError(err)
                }
                )
            
            return Disposables.create()
        }
        
    }
    
    func faceBookLogin(presenting: UIViewController, button: FBLoginButton) -> Observable<FirebaseAuth.User> {

        return Observable.create { observer in

            let _ = button.rx.signIn.subscribe(onNext: { user in

                self.user = user
                self.isRegisteredmyInfo()
                observer.onNext(user)

            }, onError: { err in

                self.err = err as NSError
                observer.onError(err)
                
                guard let reason = self.err.handleAuthenticationError() else { return }
                SCLAlertView().showTitle(
                    reason.reason, // Title of view
                    subTitle: reason.solution,
                    timeout: .none, // String of view
                    completeText: "Done", // Optional button value, default: ""
                    style: .error, // Styles - see below.
                    colorStyle: 0xA429FF,
                    colorTextButton: 0xFFFFFF
                )

            })

            return Disposables.create()
        }
    }
    
    
    lazy var loginAction: Action<(String, String), Void> = { this in
        return Action { email, password in
            
            this.apiType.login(email: email, password: password)
                .subscribe(onSuccess: { result in
                    let user = result.user
                    if user.isEmailVerified {
                        self.user = user
                        self.isRegisteredmyInfo()

                    }
                    
                    print(user)
                }, onFailure: { err in
                    self.err = err as NSError
                    
                    guard let reason = self.err.handleAuthenticationError() else { return }
                    SCLAlertView().showTitle(
                        reason.reason, // Title of view
                        subTitle: reason.solution,
                        timeout: .none, // String of view
                        completeText: "Done", // Optional button value, default: ""
                        style: .error, // Styles - see below.
                        colorStyle: 0xA429FF,
                        colorTextButton: 0xFFFFFF
                    )
                }).disposed(by: this.disposeBag)
            
            return Observable.create { _ in
                return Disposables.create()
            }
        }
    }(self)
    
    
//        func login(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//            let authentication = self.apiType.authorizationController(controller: controller, didCompleteWithAuthorization: authorization)
//
//            let _ = authentication.subscribe(onNext: { user in
//
//                let _ = self.dataManager.isFirstLogin.subscribe(onSuccess: { isFirstLogin in
//
//                    // go to main page.
//
//                }, onFailure:{ err in
//                    // go to register my info detail page.
//
//                }).disposed(by: self.disposeBag)
//
//            },
//            onError: { err in
//
//                print(err.localizedDescription)
//                // error alert is needed to show.
//
//                switch err {
//
//                // tells users it's not correct password.
//                case LoginErrors.invailedEmail:
//                    print("email isn't valified")
//                //tells users check email and velify our app.
//                case LoginErrors.invailedUser:
//                    print("user instance couldn't be unwrapped. it's nil.")
//                case LoginErrors.inVailedClientID:
//                    print("client id couldn't be unwrapped. it's nil.")
//                default:
//                    print("not meet any errors, but something happens.")
//
//                }
//
//            })
//            .disposed(by: self.disposeBag)
//
//
//        }
    
    func resetPassword() -> CocoaAction {
        return CocoaAction { _ in
            
            let resetPasswordVM = ResetPasswordVM(coordinator: self.sceneCoodinator)
            let viewController = LoginScene.resetPassword(resetPasswordVM).viewController()
            
            return self.sceneCoodinator
                .transition(to: viewController, type: .push)
                .asObservable()
                //Cannot convert return expression of type 'Observable<Never>' to return type 'Observable<Void>'
                .map { _ in }  // 上記のエラーがこれで解決する
            
        }
    }
    
    func registerEmail() -> CocoaAction {
        return CocoaAction { task in
            let registerEmailVM = RegisterEmailVM(sceneCoordinator: self.sceneCoodinator)
            let viewController =  LoginScene.emailVerify(registerEmailVM).viewController()
            return self.sceneCoodinator
                .transition(to: viewController, type: .push)
                .asObservable()
                .map {_ in }
        }
    }
    
    

}

