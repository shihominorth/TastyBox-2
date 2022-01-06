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


class LoginMainPageViewController: UIViewController, BindableType, KeyboardSetUpProtocol {
    
            
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
        
        
        emailTextField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.emailSubject)
            .disposed(by: viewModel.disposeBag)
        
        passwordTextField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.passwordSubject)
            .disposed(by: viewModel.disposeBag)
        
        Observable.combineLatest(viewModel.emailSubject, viewModel.passwordSubject)
            .flatMapLatest { email, password -> Observable<Bool> in
            
            if email.isEmpty || password.isEmpty {
                
                return Observable<Bool>.just(false)
            }
            
                return Observable<Bool>.just(true)
            }
            .bind(to: viewModel.isEnableLoginBtnSubject)
            .disposed(by: viewModel.disposeBag)
        
        
        let successStream = PublishSubject<Firebase.User>()
        let failedStream = PublishSubject<Error>()
        
        
        successStream
            .flatMapLatest({ [unowned self] user in

                self.viewModel.isRegisteredMyInfo(user: user)
                     .asObservable()

             }).subscribe(onNext: { [unowned self] isFirst in

                 self.viewModel.goToNext(isFirst: isFirst)

             })
            .disposed(by: viewModel.disposeBag)

        failedStream
            .subscribe(onNext: { err in

                print(err)
                
                err.handleAuthenticationError()?.showErrNotification()
                self.hideViewDuringLogin()
                    
            })
            .disposed(by: viewModel.disposeBag)
        
        
        
        //MARK: bind to success and failed streams
        
        //MARK: login with email and password
        
        let loginWithEmailStream = login.rx.tap
            .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .do(onNext: { _ in
               
                self.showsViewDuringLogin()
                
            })
            .withLatestFrom(viewModel.isEnableLoginBtnSubject)
            .flatMapLatest { [unowned self] isEnable in
                self.viewModel.checkIsEmptyTxtFields(isEnabled: isEnable)
            }
            .flatMapLatest { [unowned self] email, password in
                self.viewModel.login(email: email, password: password)
              
            }
            .share(replay: 1, scope: .forever)
            
        
        let loginWithEmailSucceededStream = loginWithEmailStream.compactMap { $0.element }
        let loginWithEmailFailedStream = loginWithEmailStream.compactMap { $0.error }

        loginWithEmailSucceededStream
            .bind(to: successStream)
            .disposed(by: viewModel.disposeBag)
        
        loginWithEmailFailedStream
            .bind(to: failedStream)
            .disposed(by: viewModel.disposeBag)
        
        
        let googleLoginStream = googleLoginBtn.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.asyncInstance)
            .do(onNext: { _ in
               
                self.showsViewDuringLogin()
                
            })
            .flatMapLatest { _ in
                 self.viewModel.googleLogin(presenting: self)
            }
            .share(replay: 1, scope: .forever)
            .debug("google login")
        
        let googleLoginSucceededStream = googleLoginStream.compactMap { $0.element }
        let googleLoginFailedStream = googleLoginStream.compactMap { $0.error }
        
        googleLoginSucceededStream
            .bind(to: successStream)
            .disposed(by: viewModel.disposeBag)
        
        googleLoginFailedStream
            .bind(to: failedStream)
            .disposed(by: viewModel.disposeBag)
        
        
        let appleLoginBtn = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
        
        self.loginButtonStackView.addArrangedSubview(appleLoginBtn)
       
        //MARK: login with apple
        let appleLoginStream = appleLoginBtn.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .do(onNext: { _ in
               
                self.showsViewDuringLogin()
                
            })
            .flatMap {
                return self.viewModel.appleLogin(presenting: self)
            }
            .share(replay: 1, scope: .forever)
        
        let appleLoginSucceededStream = appleLoginStream.compactMap { $0.element }
        let appleLoginFailedStream = appleLoginStream.compactMap { $0.error }
        
        appleLoginSucceededStream
            .bind(to: successStream)
            .disposed(by: viewModel.disposeBag)
        
        appleLoginFailedStream
            .bind(to: failedStream)
            .disposed(by: viewModel.disposeBag)
 

        //MARK: login with facebook
        
        let facebookLoginBtn = FBLoginButton()
        facebookLoginBtn.permissions = ["public_profile", "email"]

        self.loginButtonStackView.addArrangedSubview(facebookLoginBtn)
        
        let facebookLoginStream = facebookLoginBtn.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.asyncInstance)
            .do(onNext: { _ in
                self.showsViewDuringLogin()
                
            })
            .flatMap {
                return self.viewModel.faceBookLogin(presenting: self, button: facebookLoginBtn)
            }
            .share(replay: 1, scope: .forever)
        
        let facebookLoginSucceededStream = facebookLoginStream.compactMap { $0.element }
        let facebookLoginFailedStream = facebookLoginStream.compactMap { $0.error }
        
        facebookLoginSucceededStream
            .bind(to: successStream)
            .disposed(by: viewModel.disposeBag)
        
        facebookLoginFailedStream
            .bind(to: failedStream)
            .disposed(by: viewModel.disposeBag)
        
      
    }
    
    func showsViewDuringLogin() {
       
        let loadingview = UIView(frame: UIScreen.main.bounds)
        let indicator = UIActivityIndicatorView()
        
        loadingview.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.7411764706, alpha: 1)
        loadingview.tag = 1
        loadingview.addSubview(indicator)
        indicator.center = loadingview.center
        
        self.view.addSubview(loadingview)
        
        indicator.startAnimating()
    }
    
    func hideViewDuringLogin() {
        
        if let index = self.view.subviews.firstIndex(where: { $0.tag == 1 }) {
        
            self.view.subviews[index].removeFromSuperview()
        
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
