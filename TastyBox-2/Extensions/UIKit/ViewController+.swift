//
//  ViewController+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-08.
//

import Foundation
import UIKit
import GoogleSignIn


extension UIViewController {
    
    var tap: UITapGestureRecognizer {
        get {
            return UITapGestureRecognizer(target: self, action: #selector(dismissOnTap))
        }
        
    }
    
    
    func setUpKeyboard() {
        
        self.navigationItem.hidesBackButton = true;
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //        view.addGestureRecognizer(tap)
        dismissOnTap()
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
        
        self.view.endEditing(true)
        self.view.removeGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        })
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.endEditing(true)
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        })
        
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    
    @objc func dismissOnTap() {
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is GIDSignInButton {
            return false
        }
        return true
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
