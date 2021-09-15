//
//  RegisterUserProfileVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//
import Action
import Firebase
import Foundation
import RxSwift
import RxRelay

class RegisterMyInfoProfileVM: ViewModelBase {
    
    let apiType: RegisterMyInfoProtocol.Type
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    var userImage = BehaviorRelay(value: #imageLiteral(resourceName: "defaultUserImage").pngData())
    var isEnableDone = BehaviorRelay(value: false)
    var observeTxtFields = BehaviorRelay<String>(value: "")
    
    var userName = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    var familySize = BehaviorRelay<String>(value: "")
    var cuisineType = BehaviorRelay<String>(value: "")

    
    let cuisineTypeOptions = ["Chinese Food", "Japanese Food", "Thai food"]
    let familySizeOptions = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
    
    init(sceneCoodinator: SceneCoordinator, apiType: RegisterMyInfoProtocol.Type = RegisterMyInfoDataManager.self, user:  Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        
        self.user = user
        
        guard let displayName = user.displayName, let userEmail = user.email, let userImageURL = user.photoURL, let userImageData = try? Data(contentsOf: userImageURL) else { return }
        
        
        userName.accept(displayName)
        email.accept(userEmail)
        userImage.accept(userImageData)
    }
    
    
    lazy var registerUserAction: Action<(String, String, String, String, Data?), Void> = { this in
        
        return Action { (name, email, familySize, cuisineType, image)  in
            
            return self.apiType.userRegister(userName: name, email: email, familySize: familySize, cuisineType: cuisineType, accountImage: image).asObservable().map { _ in }
        }
    }(self)
    
    
    func userRegister(userName: String?, email: String?, familySize: String?, cuisineType: String?, accountImage: Data?)  {
        
//        let _ = self.apiType.userRegister(userName: userName, email: email , familySize: familySize, cuisineType: cuisineType, accountImage: accountImage).subscribe(onNext: { isRegistered in
//
//            if isRegistered {
//
//            } else {
//
//            }
//
//        }, onError: { err in
//
//            print("Error writing document: \(err)")
//
//        })
    }
}
