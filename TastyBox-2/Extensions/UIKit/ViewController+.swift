//
//  ViewController+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-08.
//

import Foundation
import UIKit


extension UIViewController {
    
    var tap: UITapGestureRecognizer {
        get {
           return UITapGestureRecognizer(target: self, action: #selector(tapRecognizerAction))
        }

    }
    
    
    func setUpKeyboard() {

        self.navigationItem.hidesBackButton = true;
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addGestureRecognizer(tap)
    }
    
    //MARK: keyboard delegate
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 100
            }
        }
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognizerAction))
        
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func tapRecognizerAction() {
                
        self.view.removeGestureRecognizer(tap)

        UIView.animate(withDuration: 0.3, animations: {
            self.view.endEditing(true)
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        })
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.endEditing(true)
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        })
        
    }
}
