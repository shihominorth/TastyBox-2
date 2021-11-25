//
//  RxFaceBookLoginDelegate.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-13.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import RxSwift
import RxCocoa

class RxFaceBookLoginDelegateProxy: DelegateProxy<FBLoginButton, LoginButtonDelegate>, LoginButtonDelegate {
    
    public weak private(set) var button: FBLoginButton?
    internal lazy var signInSubject = PublishSubject<FirebaseAuth.User>()
    
    public init(button: FBLoginButton) {
        self.button = button
        super.init(parentObject: button, delegateProxy: RxFaceBookLoginDelegateProxy.self)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if let err = error {
            signInSubject.onError(err)
        } else {
            

            guard let tokenString = AccessToken.current?.tokenString else {
                
                self.signInSubject.onError(LoginErrors.invailedAccessToken)
                return
                
            }
            
            let credential = FacebookAuthProvider
                .credential(withAccessToken: tokenString)
                        
            Auth.auth().signIn(with: credential) { result, err in
                
                if let err = err {
                    
                    self.signInSubject.onError(err)
                    
                } else {
                    
                    if let user = result?.user {
                        self.signInSubject.onNext(user)
                    } else {
                        print("result is nil.")
                    }
                    
                }
            }
            
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("logout")
    }
    
    
}

extension RxFaceBookLoginDelegateProxy: DelegateProxyType {
    static func registerKnownImplementations() {
        register { RxFaceBookLoginDelegateProxy(button: $0) }
    }
    
    static func currentDelegate(for object: FBLoginButton) -> LoginButtonDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: LoginButtonDelegate?, to object: FBLoginButton) {
        object.delegate = delegate
    }
}

extension Reactive where Base: FBLoginButton {
    
    public var delegate: DelegateProxy<FBLoginButton, LoginButtonDelegate> {
        return self.delegate
    }
    
    public var signIn: Observable<FirebaseAuth.User> {
        
        let proxy = RxFaceBookLoginDelegateProxy.proxy(for: base)
        proxy.signInSubject = PublishSubject<FirebaseAuth.User>()
        
        return proxy.signInSubject.asObservable()
        
    }
}
