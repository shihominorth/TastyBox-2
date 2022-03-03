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
import Action
import Firebase

enum RegisterErrors: Error {
    case registerFailed, requestRefused, invailedUser, failedTosendEmailVerification, unavailable
}


protocol RegisterAccountProtocol {
    
    static func registerEmail(email: String, password: String) -> Observable<Bool>
    static func sendEmailWithLink(email: String?) -> Observable<Bool>
    static func signUpWithPassword(email: String, password: String) -> Completable
    static func failedSignUp() -> Completable
}


final class RegisterAccountDM: RegisterAccountProtocol {
    
    enum registerStatus {
        case failed(RegisterErrors), success
    }
    
    
    // https://qiita.com/mtkmr/items/078b715d9965fea1bd04
    // 作り直し
    
    static func sendEmailWithLink(email: String?) -> Observable<Bool> {
        
        return Observable.create { observer in
            
            guard let email = email, !email.isEmpty else {
                
                observer.onError(LoginErrors.invailedEmail)
                return Disposables.create()
                
            } //ユーザーのメールアドレス
            
            let actionCodeSettings = ActionCodeSettings() //メールリンクの作成方法をFirebaseに伝えるオブジェクト
            actionCodeSettings.handleCodeInApp = true //ログインをアプリ内で完結させる必要があります
            actionCodeSettings.dynamicLinkDomain = "tastybox2.page.link"
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            //iOSデバイス内でログインリンクを開くアプリのBundle ID
            //リンクURL
            var components = URLComponents()
            components.scheme = "https"
            components.host = "tastyboxver2.page.link" //Firebaseコンソールで作成したダイナミックリンクURLドメイン
            
            let queryItemEmailName = "email" //URLにemail情報(パラメータ)を追加する
            let emailTypeQueryItem = URLQueryItem(name: queryItemEmailName, value: email)
            components.queryItems = [emailTypeQueryItem]
            
            guard let linkParameter = components.url else {
                
                observer.onError(LoginErrors.invailedUrl)
                
                return Disposables.create()
            }
            actionCodeSettings.url = linkParameter
            
            //ユーザーのメールアドレスに認証リンクを送信
            Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { err in
                if let err = err {
                    
                    observer.onError(err)
                    
                } else {
                    print("送信完了")
                    
                    //後で認証に使用するのでローカルにメールアドレスを保存しておく
                    UserDefaults.standard.set(email, forKey: "email")
                    
                    //・・・
                    //アラートを表示するなど、ユーザーにメールの確認を促す処理
                    observer.onNext(true)
                    //                    DynamicLinks.performDiagnostics(completion: nil)
                }
                
                
            }
            
            return Disposables.create()
        }
        
        
    }
    
    static func signUpWithPassword(email: String, password: String) -> Completable {
        
        return Completable.create { completable in
            
            print("success to sign up.")
            Auth.auth().createUser(withEmail: email, password: password) { result, err in
                
                if let err = err as NSError? {
                    completable(.error(err))
                }
                else {
                    completable(.completed)
                }
                
            }
            return Disposables.create ()
            
        }
    }
    
    static func failedSignUp() -> Completable {
        
        return Completable.create { completable in
            
            print("failed to sign up.")
            
            completable(.completed)
            
            return Disposables.create()
        }
        
    }
    
    
    
    
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
