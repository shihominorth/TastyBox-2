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
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap {
                return self.viewModel.googleLogin(presenting: self)
            }
            .subscribe(onNext: { user in
                print(user)
                self.showsViewDuringLogin() //ここで呼ぶのは遅い。　googleのページが閉じてから間がある。
            }
            )
            .disposed(by: viewModel.disposeBag)
        
        
        let appleLoginBtn = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
        
        
        self.loginButtonStackView.addArrangedSubview(appleLoginBtn)
      
        appleLoginBtn.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap {
                return self.viewModel.appleLogin(presenting: self)
            }
            .subscribe(onNext: { user in
                print(user)
                self.showsViewDuringLogin()
            }, onError: { err in
                print(err)
            })
            .disposed(by: viewModel.disposeBag)

        let facebookLoginBtn = FBLoginButton()
        facebookLoginBtn.permissions = ["public_profile", "email"]

        self.loginButtonStackView.addArrangedSubview(facebookLoginBtn)

        facebookLoginBtn.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap {
                return self.viewModel.faceBookLogin(presenting: self, button: facebookLoginBtn)
            }
            .subscribe(onNext: { user in
                print(user)
                self.showsViewDuringLogin() //ここで呼ぶのは遅い。　googleのページが閉じてから間がある。
            }, onError: { err in
                print(err)
            })
            .disposed(by: viewModel.disposeBag)

    }
    
    func showsViewDuringLogin() {
        let loadingview = UIView(frame: UIScreen.main.bounds)
        let indicator = UIActivityIndicatorView()
        
        loadingview.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.7411764706, alpha: 1)
        loadingview.addSubview(indicator)
        indicator.center = loadingview.center
        
        self.view.addSubview(loadingview)
        
        indicator.startAnimating()
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
