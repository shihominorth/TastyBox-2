//
//  EditShoppingListViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-26.
//

import UIKit
import RxSwift


class EditShoppingListViewController: UIViewController, BindableType {
  
    
    typealias ViewModelType = EditShoppinglistVM
    var viewModel: EditShoppinglistVM!
    

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var editBtn: UIButton!
    
    var name: String?
    var amount: String?
    
    var indexPath: IndexPath?
    var itemIsEmpty: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        amountTextField.delegate = self
        
        nameTextField.becomeFirstResponder()
        
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
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        tap.name = "dissmiss"
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {  [unowned self] notification in
                
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    
//                    if self.view.frame.origin.y == 0 {
//                                    self.view.frame.origin.y -= keyboardSize.height
//                                } else {
//                                    let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
//                                    self.view.frame.origin.y -= suggestionHeight
//                                }
                    
                    
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
//        
//        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
//            .observe(on: MainScheduler.asyncInstance)
//            .subscribe(onNext: {  [unowned self] notification in
//                
//                if self.view.frame.origin.y != 0 {
//                    self.view.frame.origin.y = 0
//                }
//            })
//            .disposed(by: viewModel.disposeBag)
    }
    
    
    @objc func tapGesture() {
  
        self.view.endEditing(true)
            
        if let tapRecognizers = self.view.gestureRecognizers?.filter({ $0.name == "dissmiss"}) {
                
                if !tapRecognizers.isEmpty {
                    let _ = tapRecognizers.map {
                        $0.cancelsTouchesInView = false
                        self.view.removeGestureRecognizer($0)
                    }
                    
                }
                
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                
                if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                }
            })
            
        }
    
}

extension EditShoppingListViewController: UITextFieldDelegate {
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

}

extension EditShoppingListViewController: SemiModalPresenterDelegate {
    
    var semiModalContentHeight: CGFloat {
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
       
        let frame = self.view.convert(editBtn.frame, from: stackView)
        print(frame.origin.y)
        return frame.origin.y + editBtn.frame.height + 20
    }
}

