//
//  LoginMainDM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-22.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import RxSwift
import RxCocoa
import Action


enum LoginErrors: Error {
    case incorrectEmail, incorrectPassword, invailedEmail, invailedUser, inVailedClientID, invailedUrl, invailedAuthentication
}

protocol LoginMainProtocol: AnyObject {
    static func loginWithGoogle(viewController presenting: UIViewController) -> Completable
    static func loginWithGoogleFunc(viewController presenting: UIViewController)  -> Observable<FirebaseAuth.User>
}

class LoginMainDM: LoginMainProtocol {
    
    
    let bag = DisposeBag()
    let uid = Auth.auth().currentUser?.uid
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    let googleLoginPublishSubject = PublishSubject<FirebaseAuth.User>()
    
    //    var isNewUser: Bool? //　observable<bool>にするべき
    //    Singleは一回のみElementかErrorを送信することが保証されているObservableです。
    //    一回イベントを送信すると、disposeされるようになってます。
    
    
    var isFirstLogin: Single<Bool> {
        
        
        return Single.create { single in
            
            guard let uid = self.uid else {
                single(.failure(LoginErrors.invailedUser))
                return Disposables.create()
            }
            
            Firestore.firestore().collection("user").document(uid).addSnapshotListener { data, err in
                
                if let err = err {
                    single(.failure(err))
                    
                } else {
                    
                    guard let data = data else { return }
                    guard let isFirst = data["isFirst"] as? Bool else {
                        
                        single(.success(true))
                        return
                        
                    }
                    single(.success(isFirst))
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    var isEmailVerified: Observable<Bool> {
        
        return Observable.create { observer in
            
            guard let result = Auth.auth().currentUser?.isEmailVerified else {
                
                observer.onError(LoginErrors.invailedUser)
                
                return Disposables.create()
            }
            
            observer.onNext(result)
            
            return Disposables.create()
        }
        
    }
        

    static func loginWithGoogleFunc(viewController presenting: UIViewController) -> Observable<FirebaseAuth.User>{
        
        return  Observable.create { observalble in
           
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return Disposables.create()
            }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(with: config, presenting: presenting) { user, err in
                
                if let err = err {
                    observalble.onError(err)
                }
                
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                
                Auth.auth().signIn(with: credential) { authResult, err in
                    
                    if let err = err {
                        observalble.onError(err)
                    } else {
                        
                        if let user = authResult?.user {
                            print(user)
                            print("success")
                            observalble.onNext(user)
                            
                        }
                    }
                }
            }
            return Disposables.create()

        }
    }
    
    static func loginWithGoogle(viewController presenting: UIViewController) -> Completable {
        
        return Completable.create { completable in
            
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return Disposables.create ()
            }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(with: config, presenting: presenting) { user, error in
                
                if let error = error {
                    completable(.error(error))
                    return
                }
                
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    completable(.error(LoginErrors.invailedAuthentication))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                
                Auth.auth().signIn(with: credential) { authResult, err in
                    
                    if let err = err {
                        completable(.error(err))
                    } else {
                        
                        if let user = authResult?.user {
                            
                            completable(.completed)
                        }
                    }
                
                }
            }
            
            return Disposables.create()
        }
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization)  -> Observable<AuthDataResult> {
        
        
        return Observable.create { observer in
            
            self.currentNonce = self.randomNonceString()
            
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                
                guard let nonce = self.currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return Disposables.create()
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return Disposables.create()
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
                        
                        observer.onError(err)
                        return
                    } else {
                        self.isUserVailed(err, result, observer)
                    }
                }
                
            }
            
            return Disposables.create()
        }
        
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow(authorizationController: UIViewController) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = authorizationController as? ASAuthorizationControllerDelegate
        authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        
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
    
    
    func login(email: String?, password: String?) -> Observable<AuthDataResult>{
        
        return Observable.create { observer in
            
            guard let email = email else {
                
                observer.onError(LoginErrors.incorrectEmail)
                
                return Disposables.create()
            }
            
            guard let password = password else {
                
                observer.onError(LoginErrors.incorrectPassword)
                
                return Disposables.create()
            }
            
            
            Auth.auth().signIn(withEmail: email, password: password) { user, err in
                
                self.isUserVailed(err, user, observer)
                
            }
            
            return Disposables.create()
        }
        
        
    }
    
    fileprivate func isUserVailed(_ err: Error?, _ user: AuthDataResult?, _ observer: AnyObserver<AuthDataResult>) {
        if let err = err {
            observer.onError(err)
        } else {
            
            guard let currentUser = Auth.auth().currentUser, currentUser.isEmailVerified else {
                observer.onError(LoginErrors.invailedEmail)
                
                //本当に何も返さなくてもいいのか？
                return
            }
            
            guard let user = user else {
                
                observer.onError(LoginErrors.invailedUser)
                
                //本当に何も返さなくてもいいのか？
                return
                
            }
            
            //                    guard let unwrappedIsNewUser = user.additionalUserInfo?.isNewUser else {
            //                        //本当に何も返さなくてもいいのか？
            //                        return
            //                    }
            //
            //                    self.isNewUser = unwrappedIsNewUser
            
            observer.onNext(user)
        }
    }
    
    func sendEmailVailidation() -> Completable {
        
        return Completable.create { completed in
            
            Auth.auth().currentUser?.sendEmailVerification { err in
                
                if let err = err {
                    
                    completed(.error(err))
                    return
                    
                } else {
                    
                    completed(.completed)
                    
                }
                
            }
            
            return Disposables.create()
        }
        
    }
    
    func googleLogin(presenting: UIViewController, callback: @escaping GIDSignInCallback) ->  Single<AuthCredential> {
        
        return Single.create { single in
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                
                single(.failure(LoginErrors.inVailedClientID))
                
                return Disposables.create()
                
            }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(with: config, presenting: presenting) { user, err in
                
                if let err = err {
                    
                    single(.failure(err))
                    
                } else {
                    
                    guard let currentUser = Auth.auth().currentUser, currentUser.isEmailVerified else {
                        
                        single(.failure(LoginErrors.invailedEmail))
                        return
                    }
                    
                    guard let user = user else {
                        
                        single(.failure(LoginErrors.invailedUser))
                        return
                    }
                    
                    
                    
                    let authentication = user.authentication
                    guard let idToken = authentication.idToken else { return }
                    
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: authentication.accessToken)
                    
                    single(.success(credential))
                }
            }
            
            return Disposables.create()
        }
        
        
    }
    
    
    
    //    func loginWithCredential(credential: AuthCredential) {
    //
    //        Auth.auth().signIn(with: credential) { authResult, error in
    //            if let error = error {
    //
    //                let authError = error as NSError
    //
    //                if isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
    //                // The user is a multi-factor user. Second factor challenge is required.
    //                let resolver = authError
    //                  .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
    //
    //                var displayNameString = ""
    //
    //                for tmpFactorInfo in resolver.hints {
    //                  displayNameString += tmpFactorInfo.displayName ?? ""
    //                  displayNameString += " "
    //                }
    //
    //                self.showTextInputPrompt(
    //                  withMessage: "Select factor to sign in\n\(displayNameString)",
    //                  completionBlock: { userPressedOK, displayName in
    //
    //                    var selectedHint: PhoneMultiFactorInfo?
    //
    //                    for tmpFactorInfo in resolver.hints {
    //                      if displayName == tmpFactorInfo.displayName {
    //                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
    //                      }
    //                    }
    //
    //                    PhoneAuthProvider.provider()
    //                      .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
    //                                         multiFactorSession: resolver
    //                                           .session) { verificationID, error in
    //                        if error != nil {
    //                          print(
    //                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
    //                          )
    //                        } else {
    //                          self.showTextInputPrompt(
    //                            withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
    //                            completionBlock: { userPressedOK, verificationCode in
    //                              let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
    //                                .credential(withVerificationID: verificationID!,
    //                                            verificationCode: verificationCode!)
    //                              let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
    //                                .assertion(with: credential!)
    //                              resolver.resolveSignIn(with: assertion!) { authResult, error in
    //                                if error != nil {
    //                                  print(
    //                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
    //                                  )
    //                                } else {
    //                                  self.navigationController?.popViewController(animated: true)
    //                                }
    //                              }
    //                            }
    //                          )
    //                        }
    //                      }
    //                  }
    //                )
    //              } else {
    //
    //                self.showMessagePrompt(error.localizedDescription)
    //                return
    //              }
    //              // ...
    //              return
    //            }
    //            // User is signed in
    //            // ...
    //    }
    
    //    func signInWithGoogle<T:Any>(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError err: Error!) ->Observable<T> {
    //
    //        return Observable.create { observer in
    //
    //            if let err = err {
    //                observer.onError(err)
    //            }
    //
    //
    //            guard let idToken = user.authentication.idToken else {
    //                return Disposables.create {}
    //            }
    //
    //            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)
    //
    //
    //            return Disposables.create()
    //
    //        }
    //    }
    
    
}

