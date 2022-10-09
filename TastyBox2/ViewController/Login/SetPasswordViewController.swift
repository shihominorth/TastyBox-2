//
//  SetPasswordViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-07.
//

import UIKit
import RxSwift
import RxCocoa
import Action

class SetPasswordViewController: UIViewController, BindableType, KeyboardSetUpProtocol{
    var viewModel: SetPasswordVM!
    
    typealias ViewModelType = SetPasswordVM
    
    
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var comfirmTxtField: UITextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var termAndConditionsBtn: UIButton!
    @IBOutlet weak var loginbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLbl.text = viewModel.email
        setUpTxtField()
        setUpKeyboard()
    }
    
    
    func bindViewModel() {
        
        
        // check if password and comfirm password is same.
        Observable
            .combineLatest(passwordTxtField.rx.text.orEmpty, comfirmTxtField.rx.text.orEmpty) { password, comfirmPassword -> Bool in
                print(password, comfirmPassword)
                
                if password.isEmpty || comfirmPassword.isEmpty {
                    return false
                } else {
                    return password == comfirmPassword
                }
                
            }
            .bind(to: viewModel.isMatchedTriger)
            .disposed(by: viewModel.disposeBag)
        
        
        self.signUpBtn.rx.tap
            .withLatestFrom(viewModel.isMatchedTriger) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
            .withLatestFrom(self.comfirmTxtField.rx.text.orEmpty)
            .bind(to: viewModel.signUpWithPasswordAction.inputs)
            .disposed(by: viewModel.disposeBag)
        
        self.signUpBtn.rx.tap
            .withLatestFrom(viewModel.isMatchedTriger.map { !$0 }) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
            .subscribe { value in
                print(value)
                print("not matched.")
            }
            .disposed(by: viewModel.disposeBag)
        
        self.loginbtn.rx.action = viewModel.toLoginMainAction()
        self.termAndConditionsBtn.rx.action = viewModel.aboutAction()
        
    }
    
    func failedSendPassword(){
        print("not matched.")
    }
    
    func setUpTxtField() {
        passwordTxtField.delegate = self
        comfirmTxtField.delegate = self
        
        passwordTxtField.becomeFirstResponder()
    }
    
}

extension SetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTxtField {
           
            passwordTxtField.resignFirstResponder()
            comfirmTxtField.becomeFirstResponder()

            return false
        }
        
        return true
    }
}
