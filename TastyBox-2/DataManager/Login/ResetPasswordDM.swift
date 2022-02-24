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

protocol ResetPasswordProtocol: AnyObject {
    static func resetPassword(email: String?) -> Completable
}

final class ResetPasswordDM: ResetPasswordProtocol {
    
   static func resetPassword(email: String?) -> Completable {
 
        
        return Completable.create { completable in
            
            
            guard let email = email else {
                
                completable(.error(PasswordResetError.invailedEmail))
                return Disposables.create()
                
            }
            
            Auth.auth().sendPasswordReset(withEmail: email, completion: { err in
                
                if let err = err {
                    
                    completable(.error(err))
                    
                } else {
                    completable(.completed)
                }
                
            }

            )

            return Disposables.create()
        }
        
    }
}
