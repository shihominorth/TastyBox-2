//
//  RegisterEmailDM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

enum RegisterErrors: Error {
    case registerFailed, requestRefused, invailedUser, failedTosendEmailVerification, unavailable
}


protocol RegisterAccountProtocol {
    
    static func registerEmail(email: String, password: String) -> Observable<Bool>
}


class RegisterAccountDM: RegisterAccountProtocol {
    
    enum registerStatus {
        case failed(RegisterErrors), success
    }
    
    
    // https://qiita.com/mtkmr/items/078b715d9965fea1bd04
    // 作り直し
    
    static func registerEmail<T: Any>(email: String, password: String) ->  Observable<T> {
        
        return Observable.create { observer in
            
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://www.example.com")
            // The sign-in operation has to always be completed in the app.
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            actionCodeSettings.setAndroidPackageName("com.example.android",
                                                     installIfNotAvailable: false, minimumVersion: "12")
            
            Auth.auth().sendSignInLink(toEmail: email,
                                       actionCodeSettings: actionCodeSettings) { error in
                
                if let error = error {
                    
                    print("Failed to register the display name: \(error.localizedDescription)")
                    observer.onError(RegisterErrors.registerFailed)
                    
                    return
                }
                
//                if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
//                    changeRequest.commitChanges(completion: { err in
//                        if let err = error {
//                            observer.onError(err)
//                        }
//                    })
//                }
                
                Auth.auth().currentUser?.sendEmailVerification { err in
                    observer.onError(RegisterErrors.failedTosendEmailVerification)
                    return
                }
                
//                if let isEmailVerified = result?.user.isEmailVerified as? T {
//                    observer.onNext(isEmailVerified)
//                } else {
//                    observer.onError(RegisterErrors.invailedUser)
//                }
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                
              
                
            }
            
            return Disposables.create {}
            
        }
    }
    
    
    
}
