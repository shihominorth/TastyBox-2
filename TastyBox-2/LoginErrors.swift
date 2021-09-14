//
//  LoginErrors.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-11.
//

import Foundation

enum LoginErrors: Error {
    case incorrectEmail, incorrectPassword, invailedEmail, invaildPassword, invailedUser, inVailedClientID, invailedUrl, invailedAuthentication, invailedAccessToken
}


extension LoginErrors {
    func handleError() -> ReasonWhyError {
 
        return ReasonWhyError(reason: "Can't use this app.", solution: "Sorry, you need to wait until we fix this trouble.", isReportRequired: true)
    }
}
