//
//  DiscoveryViewModel.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-01.
//

import Action
import FBSDKLoginKit
import Foundation
import Firebase
import RxSwift
import RxCocoa

class DiscoveryVM: ViewModelBase {
    
    //    let apiType: RegisterMyInfoProtocol.Type
    let sceneCoodinator: SceneCoordinator
    let lockObject: ActivityIndicator!
    let user: Firebase.User
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        //        self.apiType = apiType
        
        self.user = user
        self.lockObject = ActivityIndicator()
        
    }
    
    func logoutAction() {
  
        let firebaseAuth = Auth.auth()
        
        if let providerData = firebaseAuth.currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    print("Facebook Login")
                    let loginManager = LoginManager()
                    loginManager.logOut() // this is an instance function
                default:
                    print("provider is \(userInfo.providerID)")
                }
            }
        }
        
        do {
            try firebaseAuth.signOut()
            
//            let vm = LoginMainVM(sceneCoodinator: self.sceneCoodinator)
//            let vc = LoginScene.main(vm).viewController()
//            self.sceneCoodinator.transition(to: vc, type: .modal)
            
            let vm = LoadingVM(sceneCoodinator: self.sceneCoodinator)
            let vc = LoadingScene.loading(vm).viewController()
            self.sceneCoodinator.transition(to: vc, type: .root)
            
        } catch let signOutError as NSError {
            
            print("Error signing out: %@", signOutError)
            
            if let reason = signOutError.handleAuthenticationError() {
                reason.generateErrAlert()
            }
            
    
        }
        
        
    }
}
