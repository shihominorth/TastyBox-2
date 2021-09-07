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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var termsConditionsBtn: UIButton!
    var lineView = UIView()
//    @IBAction func pressBackToLoginMainSegue(_ sender: UIBarButtonItem) {
//        self.performSegue(withIdentifier: "LoginMain", sender: nil)
//    }
//
//
    override func viewDidLoad() {
        roundCorners(view: signUpBtn, cornerRadius: 5.0)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        lineView = UIView(frame: CGRect(x: 0, y: termsConditionsBtn.frame.size.height, width: termsConditionsBtn.frame.size.width, height: 1))
        
        lineView.backgroundColor = #colorLiteral(red: 0.3658907413, green: 0.3176748455, blue: 0.8702511191, alpha: 1)
        termsConditionsBtn.addSubview(lineView)
    }
    
    
    func bindViewModel() {
        createUser()
        termsConditionsBtn.rx.action = viewModel.aboutAction()
        
        signUpBtn.rx.tap
            .withLatestFrom(emailTextField.rx.text.orEmpty)
            .bind(to: viewModel.sendEmailWithLink.inputs)
            .disposed(by: viewModel.disposeBag)
    }
    
    
    @IBAction func pressBackToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       // self.performSegue(withIdentifier: "LoginMainPage", sender: nil)
    }
    
//    @IBAction func toTermsPage(_ sender: Any) {
//        let Storyboard: UIStoryboard = UIStoryboard(name: "About", bundle: nil)
//        let vc = Storyboard.instantiateViewController(withIdentifier:"about")
//        self.present(vc, animated:true, completion:nil)
//    }
    
//    @IBAction func createAccountAction(_ sender: Any) {
//        if emailTextField.text == nil || passwordTextField.text == nil || confirmPasswordTextField.text == nil {
//            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
//                
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(defaultAction)
//                
//            present(alertController, animated: true, completion: nil)
//            
//        } else if passwordTextField.text != confirmPasswordTextField.text {
//            let alertController = UIAlertController(title: "Error", message: "Two passwords are not the same.", preferredStyle: .alert)
//                
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(defaultAction)
//                
//            present(alertController, animated: true, completion: nil)
//            
//        } else {
//            self.confirm()
//        }
//    }
    
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
