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
    
    
    func handleAuthenticationError() -> Notification? {
        
        let code = self.convertToNSError().code
//        let authErrorCode = FirebaseAuth.AuthErrorCode.self
        var result: Notification?
        
        switch code {
        case rawValue(firestoreErr: .OK):
            
            result = Notification(reason: "You could login", solution: "Please try login again", isReportRequired: true)
       
        case rawValue(firestoreErr: .cancelled):
            result = Notification(reason: "Canceled", solution: "Please try login again", isReportRequired: false)
        
        case rawValue(firestoreErr: .deadlineExceeded):
            result = Notification(reason: "Session time out", solution: "You can login again if you want", isReportRequired: false)
        
        case rawValue(authenticationError: .networkError):
            result = Notification(reason: "Network Error", solution: "Please try login again when network is working.")
            
        case rawValue(authenticationError: .userNotFound):
            result = Notification(reason: "User Not Found", solution: "This account could be deleted. Please try different account.")
            
        case rawValue(authenticationError: .userTokenExpired):
            result = Notification(reason: "Login again", solution: "You might change the password. Please try again.")
            
        case rawValue(authenticationError: .tooManyRequests):
            result = Notification(reason: "Login again Later", solution: "You request login too many times. try again after a while.")
            
        case rawValue(authenticationError: .invalidEmail):
            result = Notification(reason: "Email is not correct.", solution: "Please use correct one.")
            
            
        case rawValue(authenticationError: .operationNotAllowed):
            result = Notification(reason: "Invailed email and/or password", solution: "you can't use this email and/or password.")
            
        case rawValue(authenticationError: .emailAlreadyInUse):
            result = Notification(reason: "Already used email", solution: "try different email.")
            
        case rawValue(authenticationError: .userDisabled):
            result = Notification(reason: "Disabled your account", solution: "Sorry, your account has disabled for some reason.")
            
        case rawValue(authenticationError: .wrongPassword):
            result = Notification(reason: "Wrong password", solution: "Please try again with correct one.")
            
        case rawValue(authenticationError: .weakPassword):
                   result = Notification(reason: "Weak Password", solution: "You are using weak password. To prevent any trouble related to the password, use different one.")
        
        case rawValue(authenticationError: .invalidAPIKey), rawValue(authenticationError: .appNotAuthorized),  rawValue(authenticationError: .keychainError), rawValue(authenticationError: .internalError), rawValue(authenticationError: .invalidCredential), rawValue(authenticationError: .operationNotAllowed), rawValue(authenticationError: .invalidCustomToken), rawValue(authenticationError: .customTokenMismatch):
            
            result = Notification(reason: "Can't use this app.", solution: "Sorry, you need to wait until we fix this trouble.", isReportRequired: true)
        default:
            break
        }
        
        return result
    }
  

    private func rawValue(firestoreErr: FirestoreErrorCode) -> Int {
        return firestoreErr.rawValue
    }
    
    func handleFireStoreError() -> Notification? {
        
        let code = self.convertToNSError().code
        var result: Notification?
        
        switch code {
        case rawValue(firestoreErr: .OK):
            
            return nil
            
        case rawValue(firestoreErr: .cancelled):
            result = Notification(reason: "Canceled", solution: "You can add your data again if you want. the session was canceled.", isReportRequired: false)
        
        case rawValue(firestoreErr: .deadlineExceeded):
            result = Notification(reason: "Session time out", solution: "You can try again if you want", isReportRequired: false)
            
        
        default:
            result = Notification(reason: "Something happens", solution: "We approgise for the inconvinience. Please wait to fix the bug.", isReportRequired: true)
        }

        return result
    }
}
