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
    let user: Firebase.User
    
    
    var isMenuBarOpenedRelay = BehaviorRelay<Bool>(value: false)
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
    }
    
    func setIsMenuBarOpenedRelay() -> Observable<Bool> {
        
        return Observable.create {[unowned self] observer in
            
            self.isMenuBarOpenedRelay.accept(!isMenuBarOpenedRelay.value)
            
            observer.onNext(isMenuBarOpenedRelay.value)
            
            return Disposables.create()
        }
    }
    
    
    
    
    func toRefrigerator() {
        
        let vm = RefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let vc = IngredientScene.refrigerator(vm).viewController()
        
        
        self.sceneCoodinator.transition(to:vc, type: .push)
    }
    
    func toShoppinglist() {
        
        let vm = ShoppinglistVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let vc = IngredientScene.shoppinglist(vm).viewController()
        
        
        self.sceneCoodinator.transition(to: vc, type: .push)
    }
    
    func logout() {
  
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
