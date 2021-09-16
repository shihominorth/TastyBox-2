//
//  Error+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-10.
//

import Foundation
import Firebase

extension Error {
    
    func convertToNSError() -> NSError {
        let err = self as NSError
        
        return err
    }
    
    private func rawValue(authenticationError: FirebaseAuth.AuthErrorCode) -> Int {
        return authenticationError.rawValue
    }
    
    
    func handleAuthenticationError() -> ReasonWhyError? {
        
        let code = self.convertToNSError().code
//        let authErrorCode = FirebaseAuth.AuthErrorCode.self
        var result: ReasonWhyError?
        
        switch code {
       
        case rawValue(authenticationError: .networkError):
            result = ReasonWhyError(reason: "Network Error", solution: "Please try login again when network is working.")
            
        case rawValue(authenticationError: .userNotFound):
            result = ReasonWhyError(reason: "User Not Found", solution: "This account could be deleted. Please try different account.")
            
        case rawValue(authenticationError: .userTokenExpired):
            result = ReasonWhyError(reason: "Login again", solution: "You might change the password. Please try again.")
            
        case rawValue(authenticationError: .tooManyRequests):
            result = ReasonWhyError(reason: "Login again Later", solution: "You request login too many times. try again after a while.")
            
        case rawValue(authenticationError: .invalidEmail):
            result = ReasonWhyError(reason: "Email is not correct.", solution: "Please use correct one.")
            
            
        case rawValue(authenticationError: .operationNotAllowed):
            result = ReasonWhyError(reason: "Invailed email and/or password", solution: "you can't use this email and/or password.")
            
        case rawValue(authenticationError: .emailAlreadyInUse):
            result = ReasonWhyError(reason: "Already used email", solution: "try different email.")
            
        case rawValue(authenticationError: .userDisabled):
            result = ReasonWhyError(reason: "Disabled your account", solution: "Sorry, your account has disabled for some reason.")
            
        case rawValue(authenticationError: .wrongPassword):
            result = ReasonWhyError(reason: "Wrong password", solution: "Please try again with correct one.")
            
        case rawValue(authenticationError: .weakPassword):
                   result = ReasonWhyError(reason: "Weak Password", solution: "You are using weak password. To prevent any trouble related to the password, use different one.")
        
        case rawValue(authenticationError: .invalidAPIKey), rawValue(authenticationError: .appNotAuthorized),  rawValue(authenticationError: .keychainError), rawValue(authenticationError: .internalError), rawValue(authenticationError: .invalidCredential), rawValue(authenticationError: .operationNotAllowed), rawValue(authenticationError: .invalidCustomToken), rawValue(authenticationError: .customTokenMismatch):
            
            result = ReasonWhyError(reason: "Can't use this app.", solution: "Sorry, you need to wait until we fix this trouble.", isReportRequired: true)
        default:
            break
        }
        
        return result
    }
  

    private func rawValue(firestoreErr: FirestoreErrorCode) -> Int {
        return firestoreErr.rawValue
    }
}
