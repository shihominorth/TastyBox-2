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
import FBSDKLoginKit

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
    
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: This causes ⚠️ Reentrancy anomaly was detected. - solved

        setUpKeyboard()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
//        
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
//        view.backgroundColor = #colorLiteral(red: 0.9977325797, green: 0.9879661202, blue: 0.7689270973, alpha: 1)
//        view.tag = 100
//        
//        let indicator = UIActivityIndicatorView()
//        indicator.transform = CGAffineTransform(scaleX: 2, y: 2)
//        
//        indicator.color = .orange
//        indicator.startAnimating()
//        
//        view.addSubview(indicator)
//        indicator.center = self.view.center
        
        
//        self.view.addSubview(view)
        
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
                
                self.navigationItem.hidesBackButton = true;
                
                
                loginButtonStackView.spacing = 10.0
                
                resetPasswordButton.contentHorizontalAlignment = .right
                registerButton.contentHorizontalAlignment = .right
            }else{
                print("No!")
            }
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//  
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let tapRecognizers = self.view.gestureRecognizers?.filter({ $0.name == "dissmiss"}) {
            
            if !tapRecognizers.isEmpty {
                let _ = tapRecognizers.map {
                    $0.cancelsTouchesInView = false
                    self.view.removeGestureRecognizer($0)
                }
                
            }
            
        }
    }
    
    
    
    func bindViewModel() {
        
        resetPasswordButton.rx.action = viewModel.resetPassword()
        registerButton.rx.action = viewModel.registerEmail()
        
        
        let info = Observable.combineLatest(emailTextField.rx.text.orEmpty.observe(on: MainScheduler.asyncInstance), passwordTextField.rx.text.orEmpty.observe(on: MainScheduler.asyncInstance))
        login.rx.tap
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .withLatestFrom(info)
            .bind(to: viewModel.loginAction.inputs)
            .disposed(by: viewModel.disposeBag)
        
        
//        MARK: after tap password or email text fields, cant use google login button - solved.
        let _ = googleLoginBtn.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap {
                return self.viewModel.googleLogin(presenting: self)
            }
            .subscribe(onNext: { user in
                print(user)
            }
            )
            .disposed(by: viewModel.disposeBag)
        
        
        let appleLoginBtn = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
        
        
        self.loginButtonStackView.addArrangedSubview(appleLoginBtn)
      
        appleLoginBtn.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap {
                return self.viewModel.appleLogin(presenting: self)
            }
            .subscribe(onNext: { user in
                print(user)
            }, onError: { err in
                print(err)
            })
            .disposed(by: viewModel.disposeBag)

        let facebookLoginBtn = FBLoginButton()
        facebookLoginBtn.permissions = ["public_profile", "email"]

        self.loginButtonStackView.addArrangedSubview(facebookLoginBtn)

        facebookLoginBtn.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap {
                return self.viewModel.faceBookLogin(presenting: self, button: facebookLoginBtn)
            }
            .subscribe(onNext: { user in
                print(user)
            }, onError: { err in
                print(err)
            })
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
}



extension LoginMainPageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
        case 1:
            // they work
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            
        case 2:
            // not close the keyboard
            textField.resignFirstResponder()
            self.view.endEditing(true)
            return true
            
        default:
            break
        }
        return false
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
