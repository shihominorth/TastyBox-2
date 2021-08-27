//
//  RegisterUserProfileVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Foundation
import RxSwift

class RegisterUserProfileVM: ViewModelBase {
    
    let dataManager = RegisterMyInfoDataManager()
    var cuisineType = ["Chinese Food", "Japanese Food", "Thai food"]
    var familySize = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
    
    func userRegister(userName: String?, email: String?, familySize: String?, cuisineType: String?, accountImage: Data?)  {
        
       let _ = dataManager.userRegister(userName: userName, email: email , familySize: familySize, cuisineType: cuisineType, accountImage: accountImage).subscribe(onNext: { isRegistered in
            
            if isRegistered {
                
            } else {
                
            }
            
        }, onError: { err in
            
            print("Error writing document: \(err)")
            
        })
    }
}
