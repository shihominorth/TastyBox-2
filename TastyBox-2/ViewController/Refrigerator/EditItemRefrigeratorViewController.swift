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
    @IBOutlet weak var editBtn: UIButton!
    
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
        
        setUpKeyboard()
        
    }
    
    
    func bindViewModel() {
        
        
        _ = nameTextField.rx.text.orEmpty.bind(to: viewModel.name)
        _ = amountTextField.rx.text.orEmpty.bind(to: viewModel.amount)
        
        let _ = viewModel.isEnableDone.bind(to: editBtn.rx.isEnabled)

        
        self.viewModel.isEnableDone.subscribe(onNext: { isEnable in
            
            if isEnable {
                self.editBtn.backgroundColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
                self.editBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)

            } else {
                self.editBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                self.editBtn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
            }
            
        })
        .disposed(by: viewModel.disposeBag)
      
        
        if let item = viewModel.item {
   
            //このタイミングで以下をしないと上手く動かない
            viewModel.name.accept(item.name)
            viewModel.amount.accept(item.amount)
            
            nameTextField.text = item.name
            amountTextField.text = item.amount
            editBtn.setTitle("Edit", for: .normal)
            
            _ = editBtn.rx.tap
                .subscribe(onNext: { _ in
                    
                    self.viewModel.editItem(name: self.viewModel.name.value, amount: self.viewModel.amount.value)
                })
          
        } else {
            
            
            _ = editBtn.rx.tap
                .subscribe(onNext: { _ in
                    
                    self.viewModel.addItem(name: self.viewModel.name.value, amount: self.viewModel.amount.value)
                })
            
        }
        
        
        _ = Observable.combineLatest(nameTextField.rx.text.orEmpty, amountTextField.rx.text.orEmpty)
            .subscribe { name, amount in
            
            if name.isNotEmpty && amount.isNotEmpty {
               
                // edit
                if let item = self.viewModel.item  {
                    
                    if item.name == name && item.amount == amount {
                        self.viewModel.isEnableDone.accept(false)
                    } else {
                        self.viewModel.isEnableDone.accept(true)
                    }
                // add
                } else {
                    self.viewModel.isEnableDone.accept(true)
                }
            }
            else {
                self.viewModel.isEnableDone.accept(false)
            }
                
        }
    }
    
    func setUpKeyboard() {
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.view.tapGesture))
        tap.name = "dissmiss"
        
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
