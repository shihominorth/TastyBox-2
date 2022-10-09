//
//  RxAppleDelegateProxy.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-12.
//

import Foundation
import Firebase
import AuthenticationServices
import CryptoKit
import RxSwift
import RxCocoa

class RxAppleDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>, ASAuthorizationControllerDelegate  {
    
    public weak private(set) var controller: ASAuthorizationController?
    internal lazy var signInSubject = PublishSubject<FirebaseAuth.User>()
    var currentNonce = UserDefaults.standard.string(forKey: "nonce")

    
    
    // 初期化処理
    public init(controller: ASAuthorizationController) {
        self.controller = controller
        super.init(parentObject: controller, delegateProxy: RxAppleDelegateProxy.self)
        
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
     
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = self.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: firebaseCredential) { result, err in
                if let err = err {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    self.signInSubject.onError(err)
                    
                    return
                } else {
                    //                        self.isUserVailed(err, result, observer)
                    if let user = result?.user {
                        //                            self.isEmailVerified.onNext(user.isEmailVerified)
                        self.signInSubject.onNext(user)
                    } else {
                        print("result is nil.")

                        //                            self.isEmailVerified.onNext(false)
                    }
                    
                }
            }
            
        }
        
    }
    

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.signInSubject.onError(error)
    }
   
    deinit {
        signInSubject.on(.completed)
    }
}

extension RxAppleDelegateProxy: DelegateProxyType {
    
    static func registerKnownImplementations() {
        
        register {
            
            RxAppleDelegateProxy(controller: $0)
            
        }
    }
    
    static func currentDelegate(for object: ASAuthorizationController) -> ASAuthorizationControllerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ASAuthorizationControllerDelegate?, to object: ASAuthorizationController) {
        object.delegate = delegate
    }
}

extension Reactive where Base: ASAuthorizationController {
   
    public var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
        return RxAppleDelegateProxy.proxy(for: base)
    }
    
    @available(iOS 13, *)
    public var signIn: Observable<FirebaseAuth.User> {
        
        let proxy = RxAppleDelegateProxy.proxy(for: base)
        proxy.signInSubject = PublishSubject<FirebaseAuth.User>()

        return proxy.signInSubject.asObservable()
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow(authorizationController: UIViewController) {
        let nonce = self.randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = authorizationController as? ASAuthorizationControllerDelegate
//        authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
}
