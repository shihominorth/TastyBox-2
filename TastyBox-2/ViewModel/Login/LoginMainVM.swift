//
//  LoginViewModel.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Argus Chen. All rights reserved.
//

import Foundation
import Firebase
//import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import CryptoKit
//import Crashlytics
import RxSwift
import Action


class LoginMainVM: ViewModelBase {
    
    private var userImage: UIImage = #imageLiteral(resourceName: "imageFile")
    private let dataManager = LoginMainDM()
    

    
    //    Singleは一回のみElementかErrorを送信することが保証されているObservableです。
    //    一回イベントを送信すると、disposeされるようになってます。
    var isLogined: Observable<Bool> {
        
        return Observable.create { observable in
            
            if (Auth.auth().currentUser?.uid) != nil {
                observable.onNext(true)
                
            } else {
                observable.onNext(false)
            }
            
            return Disposables.create()
        }
        
    }
    
    
    let sceneCoodinator: SceneCoordinator
    
    init(sceneCoodinator: SceneCoordinator) {
        self.sceneCoodinator = sceneCoodinator
    }
    
    
 
    
    func Login(email: String?, password: String?) {
        
        let login = dataManager.login(email: email, password: password)
        
        
        
        let _ = login.subscribe(onNext: { user in
            
            let _ = self.dataManager.isFirstLogin.subscribe(onSuccess: { successed in
                
                
                
            }, onFailure: { err in
                
            })
            
        },
        
        onError: { err in
            
            print(err.localizedDescription)
            // error alert is needed to show.
            
            switch err {
            case LoginErrors.incorrectEmail:
                print("incorrect email")
            // tells users it's not correct email
            case LoginErrors.incorrectPassword:
                print("incorrect password.")
            // tells users it's not correct password.
            case LoginErrors.invailedEmail:
                print("email isn't valified")
            //tells users check email and velify our app.
            case LoginErrors.invailedUser:
                print("user instance couldn't be unwrapped. it's nil.")
            case LoginErrors.inVailedClientID:
                print("client id ouldn't be unwrapped. it's nil.")
            default:
                print("not meet any errors, but something happens.")
                
            }
            
        })
        
    }
    
 
    func login(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        let authentication = dataManager.authorizationController(controller: controller, didCompleteWithAuthorization: authorization)
        
        let _ = authentication.subscribe(onNext: { user in
            
            let _ = self.dataManager.isFirstLogin.subscribe(onSuccess: { isFirstLogin in
                
              // go to main page.
                
            }, onFailure:{ err in
                // go to register my info detail page.
                
            }).disposed(by: self.disposeBag)
            
        },
        onError: { err in
            
            print(err.localizedDescription)
            // error alert is needed to show.
            
            switch err {
            
            // tells users it's not correct password.
            case LoginErrors.invailedEmail:
                print("email isn't valified")
            //tells users check email and velify our app.
            case LoginErrors.invailedUser:
                print("user instance couldn't be unwrapped. it's nil.")
            case LoginErrors.inVailedClientID:
                print("client id ouldn't be unwrapped. it's nil.")
            default:
                print("not meet any errors, but something happens.")
                
            }
            
        })
        .disposed(by: self.disposeBag)
        
        
    }
    
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
    
    
    lazy var registerMyProfile: Action<Void, Swift.Never> = { this in
      return Action { task in
        
        let registerAccountVM = RegisterUserProfileVM()
        let viewController = LoginScene.profileRegister(registerAccountVM).viewController()
        
        return this.sceneCoodinator
          .transition(to: viewController, type: .push)
          .asObservable()
      }
    }(self)
}
