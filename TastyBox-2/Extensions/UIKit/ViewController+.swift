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

protocol KeyboardSetUpProtocol: AnyObject {
    func setUpKeyboard()  
}


extension KeyboardSetUpProtocol where Self: UIViewController {
 
    func setUpKeyboard() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.view.tapGesture))
        tap.name = "dissmiss"
        
        self.navigationItem.hidesBackButton = true;
        
        let _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
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

        _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
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
 
}

extension UIView {
    
    @objc func tapGesture() {
        
        let sleeve = GestureClosureSleeve<UITapGestureRecognizer>({ tap in
            
            self.endEditing(true)
            
            if let tapRecognizers = self.gestureRecognizers?.filter({ $0.name == "dissmiss"}) {
                
                if !tapRecognizers.isEmpty {
                    let _ = tapRecognizers.map {
                        $0.cancelsTouchesInView = false
                        self.removeGestureRecognizer($0)
                    }
                    
                }
                
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                
                if self.frame.origin.y != 0 {
                    self.frame.origin.y = 0
                }
            })
            
        })
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(GestureClosureSleeve.invoke))
        
        self.addGestureRecognizer(recognizer)
        
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
    }
}


class GestureClosureSleeve<T: UIGestureRecognizer> {
    let closure: (_ gesture: T)->()

    init(_ closure: @escaping (_ gesture: T)->()) {
        self.closure = closure
    }

    @objc func invoke(_ gesture: Any) {
        guard let gesture = gesture as? T else { return }
        closure(gesture)
    }
}
