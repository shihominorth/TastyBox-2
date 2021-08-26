//
//  RessetPasswordDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation
import Firebase
import RxSwift

enum PasswordResetError: Error {
    case invailedEmail
}

class RessetPasswordDM {
    
    func resetPassword(email: String?) -> Observable<Bool>{
 
        
        return Observable.create { observer in
            
            
            guard let email = email else {
                
                observer.onError(PasswordResetError.invailedEmail)
                return Disposables.create()
                
            }
            
            Auth.auth().sendPasswordReset(withEmail: email, completion: { err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                } else {
                    observer.onNext(true)
                }
                
            }
            
           
            )

            return Disposables.create()
        }
        
    }
}
