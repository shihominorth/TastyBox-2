//
//  EmailLoginViewController.swift
//  Recipe-CICCC
//
//  Created by Argus Chen on 2020-01-20.
//  Copyright © 2020 Argus Chen. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
//import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import CryptoKit
//import Crashlytics
import RxSwift
import RxCocoa
import RxTimelane


class LoginMainPageViewController: UIViewController,  BindableType{
    
    var viewModel: LoginMainVM!
    
    typealias ViewModelType = LoginMainVM
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    var userImage: UIImage = #imageLiteral(resourceName: "imageFile")
    
    let vc =  UIStoryboard(name: "About", bundle: nil).instantiateViewController(withIdentifier: "about") as! AboutViewController
    var tapRecognizer: UITapGestureRecognizer?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var login: UIButton!
    
    @IBOutlet var loginButtonStackView: UIStackView!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        setUpKeyboard()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        view.backgroundColor = #colorLiteral(red: 0.9977325797, green: 0.9879661202, blue: 0.7689270973, alpha: 1)
        view.tag = 100
        
        let indicator = UIActivityIndicatorView()
        indicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        indicator.color = .orange
        indicator.startAnimating()
        
        view.addSubview(indicator)
        indicator.center = self.view.center
        
        
        self.view.addSubview(view)
        
        if let user = Auth.auth().currentUser {
            
        } else {
            
        }
        
        if Auth.auth().currentUser != nil && Auth.auth().currentUser?.uid != nil {
            // User is signed in.
            
            //            let Storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            //            let vc = Storyboard.instantiateViewController(withIdentifier: "Discovery")
            //
            //            //guard self.navigationController?.topViewController == self else { return }
            //
            //
            //            vc.modalTransitionStyle = .flipHorizontal
            //            vc.modalPresentationStyle = .overFullScreen
            //            self.navigationController?.pushViewController(vc, animated: false)
            //
            
        }
        
        else {
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
                
                // make login button rounded
                roundCorners(view: login, cornerRadius: 5.0)
                //                GIDSignIn.sharedInstance.delegate = self
                //                GIDSignIn.sharedInstance.presentingViewController = self
                // Do any additional setup after loading the view.
                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
                view.addGestureRecognizer(tap)
                
                self.navigationItem.hidesBackButton = true;
                
                emailTextField.delegate = self
                passwordTextField.delegate = self
                
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                
                setUpFaceBookLogin()
                //                setUpGoogleLogin()
                setUpSignInAppleButton()
                loginButtonStackView.spacing = 10.0
                
                resetPasswordButton.contentHorizontalAlignment = .right
                registerButton.contentHorizontalAlignment = .right
            }else{
                print("No!")
            }
            
        }
        
        
    }
    
    func bindViewModel() {
        
        resetPasswordButton.rx.action = viewModel.resetPassword()
        registerButton.rx.action = viewModel.registerEmail()
        
        //MARK: after tap password or email text fields, cant use google login button
        let _ = googleLoginBtn.rx.controlEvent(.touchUpInside)
            .flatMap {
                return self.viewModel.googleLogin(presenting: self)
            }
            .subscribe(onNext: { user in
                print(user)
            }, onError: { err in
                print(err)
            })
            .disposed(by: viewModel.disposeBag)
        
        passwordTextField.rx.controlEvent(.touchUpInside).subscribe { event in
            print("tapped.")
        }
        .disposed(by: viewModel.disposeBag)
        
        emailTextField.rx.controlEvent(.touchUpInside).subscribe { event in
            print("tapped.")
        }
        .disposed(by: viewModel.disposeBag)
        
        
        let info = Observable.combineLatest(emailTextField.rx.text.orEmpty, passwordTextField.rx.text.orEmpty)
        login.rx.tap
            .withLatestFrom(info)
            .bind(to: viewModel.loginAction.inputs)
            .disposed(by: viewModel.disposeBag)
    }
    
    
    @IBAction func unwindtoLoginMain(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Email login
    @IBAction func loginAction(_ sender: Any) {
        
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            //mention that they didn't insert the text field
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
        } else {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {
                (user, error) in
                
                if let error = error {
                    let alertController = UIAlertController(title: "Login Error", message:error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                guard let currentUser = Auth.auth().currentUser, currentUser.isEmailVerified else {
                    let alertController = UIAlertController(title: "Login Error", message:"You haven't confirmed your email address yet. We sent you a confirmation email when you sign up. Please click the verification link in that email. If you need us to send the confirmation email again, please tap Resend Email.", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Resend email", style: .default,handler: { (action) in
                        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                self.view.endEditing(true)
                self.passwordTextField.text = ""
                
                if  (user?.additionalUserInfo!.isNewUser)! {
                    
                    //                    self.vc.isFirst = true
                    
                    guard self.navigationController?.topViewController == self else { return }
                    self.navigationController?.pushViewController(self.vc, animated: true)
                    
                } else {
                    
                    Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid).addSnapshotListener { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            
                            if let data = data {
                                let isFirst = data["isFirst"] as? Bool
                                if let isFirst = isFirst {
                                    if isFirst == true {
                                        //                                        self.vc.isFirst = true
                                        
                                        guard self.navigationController?.topViewController == self else { return }
                                        self.navigationController?.pushViewController(self.vc, animated: true)
                                        
                                    } else {
                                        //                                        self.vc.isFirst = false
                                        let Storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                                        let vc = Storyboard.instantiateViewController(withIdentifier: "FirstTimeProfile")
                                        
                                        guard self.navigationController?.topViewController == self else { return }
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                } else {
                                    //                                    self.vc.isFirst = true
                                    
                                    guard self.navigationController?.topViewController == self else { return }
                                    self.navigationController?.pushViewController(self.vc, animated: true)
                                }
                            }
                            
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    //MARK: Facebook Login
    
    func setUpFaceBookLogin() {
        //        let faceBookLoginButton = FBLoginButton()
        //        let fbLoginManager = LoginManager()
        //        fbLoginManager.logOut() // this is an instance function
        //        faceBookLoginButton.layer.cornerRadius = 10
        //        faceBookLoginButton.delegate = self
        //
        //        print(faceBookLoginButton.frame.height)
        //        loginButtonStackView.addArrangedSubview(faceBookLoginButton)
    }
    
    
//        //MARK: keyboard delegate
//        @objc func keyboardWillShow(notification: NSNotification) {
//            if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//                if self.view.frame.origin.y == 0 {
//                    self.view.frame.origin.y -= 100
//                }
//            }
//
//            tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognizerAction))
//
//            self.view.addGestureRecognizer(tapRecognizer!)
//        }
//
//        @objc func tapRecognizerAction() {
//
//
//            if let tapRecognizer = tapRecognizer {
//                self.view.removeGestureRecognizer(tapRecognizer)
//                self.tapRecognizer = nil
//            }
//
//            UIView.animate(withDuration: 0.3, animations: {
//                self.view.endEditing(true)
//                if self.view.frame.origin.y != 0 {
//                    self.view.frame.origin.y = 0
//                }
//            })
//
//        }
//
//        @objc func keyboardWillHide(notification: NSNotification) {
//
//            UIView.animate(withDuration: 0.3, animations: {
//                self.view.endEditing(true)
//                if self.view.frame.origin.y != 0 {
//                    self.view.frame.origin.y = 0
//                }
//            })
//
//        }
    
    
}

//extension LoginMainPageViewController: LoginButtonDelegate {
//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//        // エラーチェック
//        if let error = error {
//            print(error)
//        } else {
//            // ログインがユーザーにキャンセルされたかどうか
//            if result!.isCancelled {
//                print("Login　Cancel")
//
//            } else {
//                //                     let fbLoginManager = LoginManager()
//                //                            fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) {(
//                //                                Result, Error) in
//                //                guard let accessToken = AccessToken.current
//                //                    else {
//                //                        print("Failed to get access token")
//                //                        return
//                //                }
//                //
//                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
//
//                Auth.auth().signIn(with: credential) { (result, error) in
//                    if let error = error {
//                        print("Failed to login: \(error.localizedDescription)")
//                        return
//                    }
//
//                    guard let accessToken = AccessToken.current
//                        else {
//                            print("Failed to get access token")
//                            return
//                    }
//
//                    // call Firebase API to signin
//
//                    if  (result?.additionalUserInfo!.isNewUser)! {
//                        if !accessToken.isExpired {
//                            self.vc.isFirst = true
//
//                            guard self.navigationController?.topViewController == self else { return }
//                            self.navigationController?.pushViewController(self.vc, animated: true)
//                        }
//                    } else {
//                        if !accessToken.isExpired {
//                            Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid).addSnapshotListener { data, error in
//                                if let error = error {
//                                    print(error.localizedDescription)
//                                } else {
//
//                                    if let data = data {
//                                        let isFirst = data["isFirst"] as? Bool
//                                        if let isFirst = isFirst {
//                                            if isFirst == true {
//                                                self.vc.isFirst = true
//
//                                                guard self.navigationController?.topViewController == self else { return }
//                                                self.navigationController?.pushViewController(self.vc, animated: true)
//
//                                            } else {
//                                                self.vc.isFirst = false
//                                                let Storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
//                                                let vc = Storyboard.instantiateViewController(withIdentifier: "FirstTimeProfile")
//
//                                                guard self.navigationController?.topViewController == self else { return }
//                                                self.navigationController?.pushViewController(vc, animated: true)
//                                            }
//                                        } else {
//                                            self.vc.isFirst = true
//                                            guard self.navigationController?.topViewController == self else { return }
//                                            self.navigationController?.pushViewController(self.vc, animated: true)
//                                        }
//                                    }
//
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
////    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
////        print("logout")
////    }
//}

extension LoginMainPageViewController: ASAuthorizationControllerDelegate {
    //MARK: Apple login
    
    func setUpSignInAppleButton() {
        
        //        let appleLoginButton = UIButton(type: .custom)
        //        appleLoginButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        //        appleLoginButton.layer.cornerRadius = 10
        //        appleLoginButton.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //        appleLoginButton.tintColor = .black
        
        //        let image = #imageLiteral(resourceName: "apple-24")
        //        appleLoginButton.setImage(image, for: .normal)
        //
        //        appleLoginButton.setTitle(" Apple ", for: .normal)
        //        appleLoginButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 20.0)
        //        appleLoginButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        //        appleLoginButton.frame.size.height = 25.0
        let appleLoginButton = ASAuthorizationAppleIDButton()
        
        
        self.loginButtonStackView.addArrangedSubview(appleLoginButton)
    }
    
    @objc func handleAppleIdRequest() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
        
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
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
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
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
    
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        currentNonce = randomNonceString()
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
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
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription)
                    return
                } else {
                    // User is signed in to Firebase with Apple.
                    // ...
                    if  (authResult?.additionalUserInfo?.isNewUser)! {
                        
                        //                        self.vc.isFirst = true
                        
                        guard self.navigationController?.topViewController == self else { return }
                        self.navigationController?.pushViewController(self.vc, animated: true)
                        
                    } else {
                        Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid).addSnapshotListener { data, error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                
                                if let data = data {
                                    let isFirst = data["isFirst"] as? Bool
                                    if let isFirst = isFirst {
                                        if isFirst == true {
                                            //                                            self.vc.isFirst = true
                                            //
                                            guard self.navigationController?.topViewController == self else { return }
                                            
                                            
                                            self.navigationController?.pushViewController(self.vc, animated: true)
                                            
                                        } else {
                                            //                                            self.vc.isFirst = false
                                            let Storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                                            let vc = Storyboard.instantiateViewController(withIdentifier: "FirstTimeProfile")
                                            
                                            guard self.navigationController?.topViewController == self else { return }
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    } else {
                                        //                                        self.vc.isFirst = true
                                        
                                        guard self.navigationController?.topViewController == self else { return }
                                        self.navigationController?.pushViewController(self.vc, animated: true)
                                    }
                                }
                                
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}


//MARK: Google login
//extension LoginMainPageViewController: GIDSignInDelegate {
//
//    //MARK: Google login
//    func setUpGoogleLogin() {
//        //        let authorizationButton = GIDSignInButton()
//        //        let googleLoginButton = UIButton(type: .custom)
//        googleLoginButton.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
//
//
//
//
//        googleLoginButton.layer.cornerRadius = 10
//        googleLoginButton.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        googleLoginButton.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        googleLoginButton.layer.borderWidth = 1
//        googleLoginButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 20.0)
//
//        googleLoginButton.titleLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//
//        googleLoginButton.setTitle(" Google ", for: .normal)
//
//        let widthAnchorImageView = googleLoginButton.imageView?.widthAnchor.constraint(equalToConstant: 28.0)
//        let heightAnchor = googleLoginButton.imageView?.heightAnchor.constraint(equalToConstant: 28.0)
//
//        //               widthAnchor!.isActive = true
//        heightAnchor?.isActive = true
//
//        let superViewCenterYAnchor = self.view.centerXAnchor
//        let width = self.loginButtonStackView.frame.width
//
//        self.loginButtonStackView.addArrangedSubview(googleLoginButton)
//        let centerYAnchor = googleLoginButton.centerXAnchor.constraint(equalTo: superViewCenterYAnchor, constant: 0.0)
//        let widthAnchor =  googleLoginButton.widthAnchor.constraint(equalToConstant: width)
//
//        centerYAnchor.isActive = true
//        widthAnchor.isActive = true
//        widthAnchorImageView?.isActive = true
//    }
//
//    @objc func googleLogin() {
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//
//        // Create Google Sign In configuration object.
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: self)
//    }
//
////    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
////        if error != nil {
////            print(error!)
////            return
////        }
////        guard let authentication = user.authentication else {
////            return
////        }
////
////        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
////
////        Auth.auth().signIn(with: credential, completion: { (user, error) in
////            if let error = error {
////                print("Login error: \(error.localizedDescription)")
////                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
////                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
////                alertController.addAction(okayAction)
////                self.present(alertController, animated: true, completion: nil)
////                return
////            }
////            // present the main view
////            if error == nil {
////
////                if  (user?.additionalUserInfo!.isNewUser)! {
////
////                    self.vc.isFirst = true
////                    guard self.navigationController?.topViewController == self else { return }
////
////                    self.navigationController?.pushViewController(self.vc, animated: true)
////
////                } else {
////
////                    if  (user?.additionalUserInfo!.isNewUser)! {
////
////                        self.vc.isFirst = true
////
////                        guard self.navigationController?.topViewController == self else { return }
////                        self.navigationController?.pushViewController(self.vc, animated: true)
////
////                    } else {
////                        Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid).addSnapshotListener { data, error in
////                            if let error = error {
////                                print(error.localizedDescription)
////                            } else {
////
////                                if let data = data {
////                                    let isFirst = data["isFirst"] as? Bool
////                                    if let isFirst = isFirst {
////                                        if isFirst == true {
////                                            self.vc.isFirst = true
////
////                                            guard self.navigationController?.topViewController == self else { return }
////                                            self.navigationController?.pushViewController(self.vc, animated: true)
////
////                                        } else {
////
////                                            UIView.animate(withDuration: 1.0) {
////                                                self.vc.isFirst = false
////                                                let Storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
////                                                let vc = Storyboard.instantiateViewController(withIdentifier: "FirstTimeProfile")
////
////                                                guard self.navigationController?.topViewController == self else { return }
////                                                self.navigationController?.pushViewController(vc, animated: true)
////                                            }
////                                        }
////                                    } else {
////                                        self.vc.isFirst = true
////
////                                        guard self.navigationController?.topViewController == self else { return }
////                                        self.navigationController?.pushViewController(self.vc, animated: true)
////                                    }
////                                }
////
////                            }
////                        }
////
////
////                    }
////                }
////            }
////        })
////
////    }
////
//
//
//}

//extension FBLoginButton {
//  /**
//   Create a new `LoginButton` with a given optional frame and read permissions.
//   - Parameter frame: Optional frame to initialize with. Default: `nil`, which uses a default size for the button.
//   - Parameter permissions: Array of read permissions to request when logging in.
//   */
//  convenience init(frame: CGRect = .zero, permissions: [Permission] = [.publicProfile]) {
//    self.init(frame: frame)
//    self.permissions = permissions.map { $0.name }
//  }
//}

extension LoginMainPageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
        case 1:
            // they work
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            break
        case 2:
            // not close the keyboard
            textField.resignFirstResponder()
            break
        default:
            break
        }
        return true
    }
    
}

extension LoginMainPageViewController{
    func roundCorners(view: UIView, cornerRadius: Double) {
        view.layer.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
    }
}

extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
