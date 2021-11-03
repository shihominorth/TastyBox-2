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
    
    let presenter = DiscoveryPresenter()
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
   
    var isMenuBarOpenedRelay = BehaviorRelay<Bool>(value: false)
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
            
    }
    
    
    func sideMenuTapped() {
        
        presenter.sideMenuVC?.tableView.rx.itemSelected
            .debug("item selected")
            .subscribe(onNext: { [unowned self] indexPath in
                
                presenter.sideMenuVC?.tableView.deselectRow(at: indexPath, animated: true)
               
                switch indexPath.row {
                    
                case 0:
                    
                    self.toMyProfile()
                
                case 2:
                    self.toRefrigerator()
                    
                case 3:
                    self.toShoppinglist()
                    
                case 6:
                    self.logout()
                    
                default:
                    break
                    
                }
                
                
            }, onError: { err in
                print(err)
            })
            .disposed(by: self.disposeBag)
    }
    
    func setIsMenuBarOpenedRelay() -> Observable<Bool> {
        
        return Observable.create {[unowned self] observer in
            
            self.isMenuBarOpenedRelay.accept(!isMenuBarOpenedRelay.value)
            
            observer.onNext(isMenuBarOpenedRelay.value)
            
            return Disposables.create()
        }
    }
    
    
    func toCreateRecipeVC() {
        
        let vm = CreateRecipeVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
//        let vc = CreateRecipeScene.createRecipe(vm).viewController()
//
//        self.sceneCoodinator.transition(to: vc, type: .push)
        
        self.sceneCoodinator.modalTransition(to: .createReceipeScene(scene: .createRecipe(vm)), type: .modal(presentationStyle: .none, modalTransisionStyle: .coverVertical, hasNavigationController: true))
    }
    
    func toMyProfile() {
        
        let vm = MyProfileVM(sceneCoordinator: self.sceneCoodinator, user: self.user)
        
        self.sceneCoodinator.modalTransition(to: .profileScene(scene: .myprofile(vm)), type: .push)
        
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
