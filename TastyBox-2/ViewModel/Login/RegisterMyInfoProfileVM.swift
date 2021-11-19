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
import SCLAlertView

class RegisterMyInfoProfileVM: ViewModelBase {
    
    let apiType: RegisterMyInfoProtocol.Type
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let defaultUserImageData = #imageLiteral(resourceName: "defaultUserImage").pngData()
    var userImage: BehaviorRelay<Data>!
    var isEnableDone = BehaviorRelay(value: false)
    var observeTxtFields = BehaviorRelay<String>(value: "")
    
    var userName = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    var familySize = BehaviorRelay<String>(value: "")
    var cuisineType = BehaviorRelay<String>(value: "")
    
    
    let cuisineTypeOptions = ["Chinese Food", "Japanese Food", "Thai food"]
    let familySizeOptions = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
    
    init(sceneCoodinator: SceneCoordinator, apiType: RegisterMyInfoProtocol.Type = RegisterMyInfoDM.self, user:  Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        
        self.user = user
        
        guard let displayName = user.displayName, let userEmail = user.email else { return }
        
        
        userName.accept(displayName)
        email.accept(userEmail)
        
    }
    
    func getUserImage() -> Observable<Data> {
        
        return self.apiType.getUserImage(user: self.user)
            .catch { err in
                
                if let userImageURL = self.user.photoURL, let userImageData = try? Data(contentsOf: userImageURL) {
                    return Observable.just(userImageData)
                }
                
                else if let defaultUserImageData = self.defaultUserImageData {
                    return Observable.just(defaultUserImageData)
                }
                
                return .empty()
                
            }
            .do(onNext: { [unowned self] data in
                
                self.userImage = BehaviorRelay<Data>(value: data)
            })
                
                
                }
    
    func registerUser() -> Observable<Void> {
        
        return Observable.combineLatest(userName.asObservable(), email.asObservable(), familySize.asObservable(), cuisineType.asObservable(), userImage.asObservable())
            .flatMap { [unowned self] (name, email, familySize, cuisineType, userImage)  in
                self.apiType.userRegister(userName: name, email: email, familySize: familySize, cuisineType: cuisineType, accountImage: userImage)
            }
            .catch { err in
                
                print(err)
                
                guard let reason = err.handleFireStoreError() else { return .empty() }
                
                SCLAlertView().showTitle(
                    reason.reason, // Title of view
                    subTitle: reason.solution,
                    timeout: .none, // String of view
                    completeText: "Done", // Optional button value, default: ""
                    style: .error, // Styles - see below.
                    colorStyle: 0xA429FF,
                    colorTextButton: 0xFFFFFF
                )
                
                return .empty()
            }
        
    }
    
    func goToNext() {
 
        let vm = DiscoveryVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let vc = DiscoveryScene.discovery(vm).viewController()
        self.sceneCoodinator.transition(to: vc, type: .modal(presentationStyle: nil, modalTransisionStyle: .crossDissolve, hasNavigationController: false))
        
    }
    
}
