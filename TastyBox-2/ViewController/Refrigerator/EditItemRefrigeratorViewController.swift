//
//  AddItemRefrigeratorViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import UIKit
import RxCocoa
import RxSwift

class EditItemRefrigeratorViewController: UIViewController, BindableType {
   
    
    typealias ViewModelType = EditItemRefrigeratorVM
    
    var viewModel: EditItemRefrigeratorVM!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    var name: String?
    var amount: String?
    
    var indexPath: IndexPath?
//    weak var delegate: AddingIngredientRefrigeratorViewControllerDelegate?
    var itemIsEmpty: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        amountTextField.delegate = self
        
        if name != nil, amount != nil {
            nameTextField.text = name
            amountTextField.text = amount
        }
        
//        setUpKeyboard()
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {  [unowned self] notification in
                
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    
                    if nameTextField.isFirstResponder {
                        if let frame = nameTextField.superview?.convert(nameTextField.frame, to: nil) {
                            
                            if frame.origin.y > keyboardSize.origin.y + 10 {
                                self.view.center.y -= 100
                            }
                            
                        }
                    }
                    else if amountTextField.isFirstResponder {
                        if let frame = nameTextField.superview?.convert(amountTextField.frame, to: nil) {
                            
                            if frame.origin.y > keyboardSize.origin.y + 10 {
                                self.view.center.y -= 100
                            }
                            
                        }
                    }
                    
                }
                
                if let gestureRecognizers = self.view.gestureRecognizers  {
                    
                    if gestureRecognizers.filter({ $0.name == "dissmiss"}).isEmpty {
                        self.view.addGestureRecognizer(tap)
                        self.view.gestureRecognizers![0].name = "dissmiss"
                    }
                    
                } else {
                    
                    
                    self.view.addGestureRecognizer(tap)
                    self.view.gestureRecognizers![0].name = "dissmiss"
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {  [unowned self] notification in
                
                if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                }
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    
    func bindViewModel() {
        
        _ = nameTextField.rx.text.orEmpty.bind(to: viewModel.name)
        _ = amountTextField.rx.text.orEmpty.bind(to: viewModel.amount)
        
        let _ = viewModel.isEnableDone.bind(to: addBtn.rx.isEnabled)

        
        _ = Observable.combineLatest(nameTextField.rx.text.orEmpty, amountTextField.rx.text.orEmpty)
            .subscribe { name, amount in
            
            if name.isNotEmpty && amount.isNotEmpty {
                self.viewModel.isEnableDone.accept(true)
            }
            else {
                self.viewModel.isEnableDone.accept(false)
            }
        }
        
       _ = addBtn.rx.tap
            .subscribe(onNext: { _ in
                self.viewModel.addItem(name: self.viewModel.name.value, amount: self.viewModel.amount.value)
            })
    }
    
    
    @IBAction func done(_ sender: Any) {
        
//        if itemIsEmpty! {
//            self.delegate?.addIngredient(controller: self, name: nameTextField.text ?? "NONE", amount: amountTextField.text ?? "NONE")
//        } else {
//            self.delegate?.editIngredient(controller: self,  name: nameTextField.text ?? "NONE", amount: amountTextField.text ?? "NONE")
//        }
//
        navigationController?.popViewController(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension EditItemRefrigeratorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            nameTextField.resignFirstResponder()
            amountTextField.becomeFirstResponder()
        case 1:
            amountTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
//
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y = 0
            }
        }
    }

    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
