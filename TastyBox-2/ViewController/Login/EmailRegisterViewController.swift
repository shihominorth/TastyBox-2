//
//  EmailRegisterViewController.swift
//  Recipe-CICCC
//
//  Created by Argus Chen on 2019-12-10.
//  Copyright © 2019 Argus Chen. All rights reserved.
//

import Foundation
import Firebase
//import Crashlytics

class EmailRegisterViewController: UIViewController, BindableType {
    
    var viewModel: RegisterEmailVM!
    typealias ViewModelType = RegisterEmailVM
    
 
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var sendLinkBtn: UIButton!
    
    @IBOutlet weak var termsConditionsBtn: UIButton!
    @IBOutlet weak var toLoginMainBtn: UIButton!
    
    var lineView = UIView()
//    @IBAction func pressBackToLoginMainSegue(_ sender: UIBarButtonItem) {
//        self.performSegue(withIdentifier: "LoginMain", sender: nil)
//    }
//
//
    override func viewDidLoad() {
        roundCorners(view: sendLinkBtn, cornerRadius: 5.0)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        lineView = UIView(frame: CGRect(x: 0, y: termsConditionsBtn.frame.size.height, width: termsConditionsBtn.frame.size.width, height: 1))
        
        lineView.backgroundColor = #colorLiteral(red: 0.3658907413, green: 0.3176748455, blue: 0.8702511191, alpha: 1)
        termsConditionsBtn.addSubview(lineView)
    }
    
    
    func bindViewModel() {
        createUser()
        termsConditionsBtn.rx.action = viewModel.aboutAction()
        
       _ = sendLinkBtn.rx.tap
            .subscribe { _ in
                
                self.view.endEditing(true)
            }
        
        sendLinkBtn.rx.tap
            .withLatestFrom(emailTextField.rx.text.orEmpty)
            .bind(to: viewModel.sendEmailWithLink.inputs)
            .disposed(by: viewModel.disposeBag)
        
        toLoginMainBtn.rx.action = viewModel.toLoginMainAction()
    }
    
    
    @IBAction func pressBackToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       // self.performSegue(withIdentifier: "LoginMainPage", sender: nil)
    }
    
    
    private func confirm(){
        let alertController = UIAlertController(title: "Terms of Service Agreement", message: "Please make sure you read the terms and conditions carefully before using the app. Do you agree to these terms of agreement?", preferredStyle: .alert)
                                  
        let agreeAction = UIAlertAction(title: "Agree", style: .cancel) { action in
            self.createUser()
        }
        let disagreeAction = UIAlertAction(title: "Disagree", style: .default, handler: { action in
        })
        alertController.addAction(agreeAction)
        alertController.addAction(disagreeAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showAlert(title: String, message: String) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    fileprivate func showErrorAlert() {

        self.showAlert(title: "Registration Error", message: "Try registration again.  Something happened for some reason.")

    }
    
    private func createUser(){
        
        let _ = viewModel.isRegistered?.subscribe(onSuccess: { isRegistered in
            
            if isRegistered {
                
                self.showAlert(title: "Email Verification Sent", message: "We've just sent a confirmation email to your email address. Please check yourinbox and click the verification link in that email to complete the sign up.")
                
            } else {
                self.showErrorAlert()
            }
            
        }, onFailure: { err in
            self.showErrorAlert()
            print(err)
        })
            

    }
}
extension EmailRegisterViewController{
    func roundCorners(view: UIView, cornerRadius: Double) {
        view.layer.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
    }
    
}
