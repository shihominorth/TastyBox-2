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

class LoginMainVM {
    private var userImage: UIImage = #imageLiteral(resourceName: "imageFile")
    private let dataManager = LoginMainDM()
    
    func Login(email: String?, password: String?) {
        
        let login = dataManager.login(email: email, password: password)
        
        let _ = login.subscribe(onNext: { user in
            
        let _ = self.dataManager.isFirstLogin.subscribe(onNext: { isFirstLogin in
                
                if isFirstLogin {
                    // go to register my info detail page.
                } else {
                    // go to main page.
                }
                
            }, onError: { err in
                print(err.localizedDescription)
                // error alert is needed to show.
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
            
            let _ = self.dataManager.isFirstLogin.subscribe(onNext: { isFirstLogin in
                    
                    if isFirstLogin {
                        // go to register my info detail page.
                    } else {
                        // go to main page.
                    }
                    
                }, onError: { err in
                    print(err.localizedDescription)
                    // error alert is needed to show.
                })
                
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
        
    
    }
}
