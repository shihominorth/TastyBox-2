//
//  ResetPasswordViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import UIKit
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa
//import Crashlytics

class ResetPasswordViewController: UIViewController, BindableType {
    var viewModel: ResetPasswordVM!
    

    typealias ViewModelType = ResetPasswordVM
    
    
//    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        roundCorners(view: submitBtn, cornerRadius: 5.0)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func bindViewModel() {
//        cancelBtn.rx.action = viewModel.cancelAction
        
        _ = submitBtn.rx.tap.subscribe(onNext: { _ in
            self.view.endEditing(true)
        })
        
        submitBtn.rx.tap
            .withLatestFrom(emailTextField.rx.text.orEmpty)
            .bind(to: viewModel.resetPasswordAction.inputs)
            .disposed(by: viewModel.disposeBag)
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        if self.emailTextField.text == "" {
                let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            
            } else {
                Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
                    
                var title = ""
                var message = ""
                    
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.emailTextField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
}
    

extension ResetPasswordViewController{
    func roundCorners(view: UIView, cornerRadius: Double) {
        view.layer.cornerRadius = CGFloat(cornerRadius)
        view.clipsToBounds = true
    }
}
