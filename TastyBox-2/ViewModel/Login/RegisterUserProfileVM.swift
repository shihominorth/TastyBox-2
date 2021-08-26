//
//  RegisterUserProfileVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Foundation

class RegisterUserProfileVM {
    
    let dataManager = RegisterMyInfoDataManager()
    
    func userRegister(userName: String, email: String, familySize: Int, cuisineType: String, accountImage: Data?, isVIP: Bool) {
        
        let _ = dataManager.userRegister(userName: userName, email: email , familySize: familySize, cuisineType: cuisineType, accountImage: accountImage, isVIP: isVIP).subscribe(onNext: { isRegistered in
            
            if isRegistered {
                
            } else {
                
            }
            
        }, onError: { err in
            
            print("Error writing document: \(err)")
            
        })
    }
}
