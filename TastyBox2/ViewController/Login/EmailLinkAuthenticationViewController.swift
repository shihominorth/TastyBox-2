//
//  EmailRegisterViewController.swift
//  Recipe-CICCC
//
//  Created by Argus Chen on 2019-12-10.
//  Copyright © 2019 Argus Chen. All rights reserved.
//

import Foundation
import Firebase
import SCLAlertView
import RxSwift
//import Crashlytics

class EmailLinkAuthenticationViewController: UIViewController, BindableType {
    
    var viewModel: EmailLinkAuthenticationVM!
    typealias ViewModelType = EmailLinkAuthenticationVM
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var sendLinkBtn: UIButton!
    
    @IBOutlet weak var termsConditionsBtn: UIButton!
    @IBOutlet weak var toLoginMainBtn: UIButton!
    
    override func viewDidLoad() {
        
        roundCorners(view: sendLinkBtn, cornerRadius: 5.0)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        let lineView = UIView(frame: CGRect(x: 0, y: termsConditionsBtn.frame.size.height, width: termsConditionsBtn.frame.size.width, height: 1))
        
        lineView.backgroundColor = #colorLiteral(red: 0.3658907413, green: 0.3176748455, blue: 0.8702511191, alpha: 1)
        termsConditionsBtn.addSubview(lineView)
        
        self.emailTextField.becomeFirstResponder()
    }
    
    
    func bindViewModel() {
        
        //        isUserRegistered()
        termsConditionsBtn.rx.action = viewModel.aboutAction()
        
        
        emailTextField.rx.text.orEmpty
            .compactMap { $0 }
            .bind(to: viewModel.emailSubject)
            .disposed(by: viewModel.disposeBag)
        
        setUpSendLinkStreams()
        
        toLoginMainBtn.rx.action = viewModel.toLoginMainAction()
    }
    
    func setUpSendLinkStreams() {
        
        sendLinkBtn.rx.tap
            .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                
                self.view.endEditing(true)
                
            })
            .bind(to: viewModel.sendLinkTrigger)
            .disposed(by: viewModel.disposeBag)
        
        
        viewModel.successStream
                .subscribe(onNext: { _ in
                    
                    
                    SCLAlertView().showTitle(
                        "Sent Email Validation", // Title of view
                        subTitle: "Please Check your email and open the link.",
                        timeout: .none, // String of view
                        completeText: "OK", // Optional button value, default: ""
                        style: .success, // Styles - see below.
                        colorStyle: 0xA429FF,
                        colorTextButton: 0xFFFFFF
                    )
                    
                    
                })
                .disposed(by: viewModel.disposeBag)
                
        viewModel.errorStream
            .subscribe(onNext: { err in
                    
                guard let reason = err.handleAuthenticationError() else {
                        
                    SCLAlertView().showTitle(
                        "Error", // Title of view
                        subTitle: "You can't login.",
                        timeout: .none, // String of view
                        completeText: "Done", // Optional button value, default: ""
                        style: .error, // Styles - see below.
                        colorStyle: 0xA429FF,
                        colorTextButton: 0xFFFFFF
                    )
                        
                    return
                }
                    
                reason.showErrNotification()
                    
            })
            .disposed(by: viewModel.disposeBag)
                
    }
    
    
    //    @IBAction func pressBackToLogin(_ sender: Any) {
    //        self.navigationController?.popViewController(animated: true)
    //       // self.performSegue(withIdentifier: "LoginMainPage", sender: nil)
    //    }
    
    
    //MARK: for email and password authentication
    
    
    //    private func confirm() {
    //        let alertController = UIAlertController(title: "Terms of Service Agreement", message: "Please make sure you read the terms and conditions carefully before using the app. Do you agree to these terms of agreement?", preferredStyle: .alert)
    //
    //        let agreeAction = UIAlertAction(title: "Agree", style: .cancel) { action in
    //            self.isUserRegistered()
    //        }
    //        let disagreeAction = UIAlertAction(title: "Disagree", style: .default, handler: { action in
    //        })
    //        alertController.addAction(agreeAction)
    //        alertController.addAction(disagreeAction)
    //        self.present(alertController, animated: true, completion: nil)
    //    }
    
    //    fileprivate func showAlert(title: String, message: String) {
    //
    //        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    //        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    //        alertController.addAction(okayAction)
    //        self.present(alertController, animated: true, completion: nil)
    //
    //    }
    //
    //    fileprivate func showErrorAlert() {
    //
    //        self.showAlert(title: "Registration Error", message: "Try registration again.  Something happened for some reason.")
    //
    //    }
    
    //MARK: for email and password authentication
    
    //    private func isUserRegistered(){
    //
    //        let _ = viewModel.isRegistered?.subscribe(onSuccess: { isRegistered in
    //
    //            if isRegistered {
    //
    //                self.showAlert(title: "Email Verification Sent", message: "We've just sent a confirmation email to your email address. Please check yourinbox and click the verification link in that email to complete the sign up.")
    //
    //            } else {
    //                self.showErrorAlert()
    //            }
    //
    //        }, onFailure: { err in
    //            self.showErrorAlert()
    //            print(err)
    //        })
    //
    //
    //    }
}
extension EmailLinkAuthenticationViewController{
    func roundCorners(view: UIView, cornerRadius: Double) {
        view.layer.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
    }
    
}
