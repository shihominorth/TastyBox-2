//
//  ViewController+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-08.
//

import Foundation
import UIKit
import GoogleSignIn
import RxSwift


extension UIViewController {
    
    var tap: UITapGestureRecognizer {
        get {
            return UITapGestureRecognizer(target: self, action: #selector(tapRecognizerAction))
        }
        
    }
    
    
    func setUpKeyboard() {
        
        let bag = DisposeBag()
        self.navigationItem.hidesBackButton = true;
        
        let keyboardShown = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe ( onNext: { [unowned self] notification in
                
                guard let userInfo = notification.userInfo else { return }
                
                
                if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= 100
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
//            .disposed(by: bag)

        let keyboardClosed = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe( onNext: { notification in


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
            })
//            .disposed(by: bag)
 
    }
    
    
    
    @objc func tapRecognizerAction() {
        
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

