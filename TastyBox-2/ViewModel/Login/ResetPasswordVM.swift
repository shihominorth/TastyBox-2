//
//  ResetPasswordVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Foundation
import RxSwift
import Action

class ResetPasswordVM: ViewModelBase {
 
    let dataManager = RessetPasswordDM()
    let cancelAction: CocoaAction
    
    init(coordinator: SceneCoordinator, cancelAction: CocoaAction? = nil) {
        self.cancelAction = CocoaAction {
            if let cancelAction = cancelAction {
              cancelAction.execute(())
            }
            return coordinator.pop()
              .asObservable()
              .map { _ in }
        }
    }
    
    func resetPassword(email: String?) {
        _ = dataManager.resetPassword(email: email).subscribe(onNext: { isSentRequest in
            
            
            
        }, onError: { err in
        
            print(err.localizedDescription)
            // error alert is needed to show.
            
            switch err {
            case PasswordResetError.invailedEmail:
                print("incorrect email")
            default:
                print("not meet any errors, but something happens.")
                
            }
        })
        
        
    }
}
