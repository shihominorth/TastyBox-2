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

protocol LoginMainProtocol: AnyObject {
    static var isRegisterMyInfo: Single<Bool> { get }
    static func login(email: String?, password: String?) -> Single<AuthDataResult>
    static func loginWithGoogle(viewController presenting: UIViewController) -> Single<Firebase.User>
    static func startSignInWithAppleFlow(authorizationController: UIViewController) -> Observable<ASAuthorizationController>
    static func logined(user: Firebase.User) -> Observable<Firebase.User>
}

class LoginMainDM: LoginMainProtocol {

    let bag = DisposeBag()
    static let uid = Auth.auth().currentUser?.uid
    // Unhashed nonce.
    fileprivate static var currentNonce: String?
        
    
    //    var isNewUser: Bool? //　observable<bool>にするべき
    //    Singleは一回のみElementかErrorを送信することが保証されているObservableです。
    //    一回イベントを送信すると、disposeされるようになってます。
    
    
   static var isRegisterMyInfo: Single<Bool> {
        
        
        return Single.create { single in
            
            guard let uid = self.uid else {
                single(.failure(LoginErrors.invailedUser))
                return Disposables.create()
            }
            
            
            Firestore.firestore().collection("users").document(uid).addSnapshotListener { data, err in
                
                if let err = err {
                    single(.failure(err))
                    
                } else {
                    
                    guard let data = data else { return }
                    guard let isFirst = data.get("isFirst") as? Bool else {
                        
                        single(.success(true))
                        return
                        
                    }
                    single(.success(isFirst))
                }
            }
            
            return Disposables.create()
        }
        
    }
    
 
   static func login(email: String?, password: String?) -> Single<AuthDataResult>{
        
        return Single.create { single in
            
            guard let email = email else {
                
                single(.failure(LoginErrors.invailedEmail))
                
                return Disposables.create()
            }
            
            guard let password = password else {
                
                single(.failure(LoginErrors.invaildPassword))
                
                return Disposables.create()
            }
            
            
            Auth.auth().signIn(withEmail: email, password: password) { result, err in
                
                if let err = err {
                    single(.failure(err))
                } else {
                    
                    if let result = result {
//                        self.isEmailVerified.onNext(user.isEmailVerified)
                        single(.success(result))
                    } else {
//                        self.isEmailVerified.onNext(false)
                        single(.failure(LoginErrors.invailedUser))
                    }
                   

                }
                
            }
            
            return Disposables.create()
        }
        
        
    }
        
    //MARK:　problem： ローディングビューが出るのが遅い
    
    // - guessed solution
    // クロージャーの中で何かをFirebaseAuth.Userの前に返し、ローディングビューをその結果の元出す
    // FirebaseAuth.Userはこのクラスの中にObservableプロパティ（おそらくSubject)onNext()する。
    // それをVMではSubscribeする
    
    static func loginWithGoogle(viewController presenting: UIViewController) -> Single<FirebaseAuth.User> {
        
        return Single.create { single in
            
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return Disposables.create ()
            }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(with: config, presenting: presenting) { user, err in
                
                if let err = err {
                    single(.failure(err))
                    return
                }
                
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    single(.failure(LoginErrors.invailedAuthentication))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                
                Auth.auth().signIn(with: credential) { authResult, err in
                    
                    if let err = err {
                        single(.failure(err))
                    } else {
                        
                        if let user = authResult?.user {
                            
                            single(.success(user))
                        }
                    }
                
                }
            }
            
            return Disposables.create {
                print("dispose")
            }
        }
    }
    
    @available(iOS 13, *)
    static func startSignInWithAppleFlow(authorizationController: UIViewController) -> Observable<ASAuthorizationController> {
       
        return Observable.create { observer in
            
            let nonce = self.randomNonceString()
            self.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                    authorizationController.delegate = authorizationController as? ASAuthorizationControllerDelegate
            authorizationController.presentationContextProvider = authorizationController as? ASAuthorizationControllerPresentationContextProviding
            
            authorizationController.performRequests()
            UserDefaults.standard.set(nonce, forKey: "nonce")

            observer.onNext(authorizationController)
            
            return Disposables.create()
        }
        
    }
    
    
    
    @available(iOS 13, *)
    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    private static func randomNonceString(length: Int = 32) -> String {
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
    
    
   
    
    fileprivate func isUserVailed(_ err: Error?, _ user: AuthDataResult?, _ single: Single<AuthDataResult>) {
        
//        if let err = err {
        
//            single(.failure(err))
        
//        } else {
//
//            guard let currentUser = Auth.auth().currentUser, currentUser.isEmailVerified else {
//                single.onError(LoginErrors.invailedEmail)
                
                //本当に何も返さなくてもいいのか？
//                return
//            }
            
//            guard let user = user else {
//
//                single.onError(LoginErrors.invailedUser)
//
//                //本当に何も返さなくてもいいのか？
//                return
//
//            }
            
            //                    guard let unwrappedIsNewUser = user.additionalUserInfo?.isNewUser else {
            //                        //本当に何も返さなくてもいいのか？
            //                        return
            //                    }
            //
            //                    self.isNewUser = unwrappedIsNewUser
            
//            single.onNext(user)
//        }
    }
    
    static func logined(user: Firebase.User) -> Observable<Firebase.User> {
        
        return Observable.create { observer in
            
            Firestore.firestore().collection("users").document(user.uid).setData([
                
                "id": user.uid,
                "isVIP": false,
                "isFirst": false
                
            ] , merge: true) { err in
                    if let err = err {
                       
                        observer.onError(err)
                        
                    } else {
                        
                        observer.onNext(user)
                    }
                }
            
            return Disposables.create()
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

    
}

