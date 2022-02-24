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
import Photos
import RxSwift
import RxCocoa

class DiscoveryVM: ViewModelBase {
    
    let presenter: DiscoveryPresenter
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
//    let selectedIndexRelay: BehaviorRelay<Int>
    let isMenuBarOpenedRelay: BehaviorRelay<Bool>
    
    var selectedIndex: Int
    let pages: [String]
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.presenter = DiscoveryPresenter(user: user, sceneCoordinator: self.sceneCoodinator)
//        self.selectedIndexRelay = BehaviorRelay<Int>(value: 1)
        self.isMenuBarOpenedRelay = BehaviorRelay<Bool>(value: false)
        self.selectedIndex = 1
        
        
        let label1 = "Subscribed Creator"
        let label2 = "Your Ingredients Recipe"
        let label3 = "Most Popular"
//        let label4 = "Editor Choice"
//        let label5 = "Cuisine Choice"
//        let label6 = " VIP Only "
        
        self.pages = [label1, label2, label3]
        
        // appendする方がコンパイル時間が短くなるがvarにしなければならない
        //
//        pages.append(label1)
//        pages.append(label2)
//        pages.append(label3)
//        arrayMenu.append(label4)
//        arrayMenu.append(label5)
//        arrayMenu.append(label6)
    }
    
    
    func setDefaultViewControllers() {
        
    
        presenter.setDefaultViewController()
        
    }
    
    func sideMenuTapped() {
        
        self.presenter.sideMenuVC?.tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                
                presenter.sideMenuVC?.tableView.deselectRow(at: indexPath, animated: true)
               
                switch indexPath.row {
                    
                case 0:
                    
                    self.toMyProfile()
                
                case 1:
                    self.toRefrigerator()
                    
                case 2:
                    self.toShoppinglist()
                    
                case 3:
                    
                    self.toContactForm()
                    
                case 4:
                    
                    self.toAboutPage()
                    
                case 5:
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
    
    func selectPageTitle(row: Int) {
        
        self.presenter.setViewControllers(row: row)
        
    }
    
    
    func toCreateRecipeVC() {
        
        let vm = SelectDigitalContentsVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: .recipeMain(.image), isEnableSelectOnlyOneDigitalContentType: false)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectDigitalContents(vm))

        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: true))

    }
    
    func toMyProfile() {
        
        let vm = MyProfileVM(sceneCoordinator: self.sceneCoodinator, user: self.user)
        
        self.sceneCoodinator.transition(to: .profileScene(scene: .myProfile(vm)), type: .push)
        
    }
    
    func toRefrigerator() {
        
        let vm = RefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let scene: Scene = .ingredient(scene: .refrigerator(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .push)
    }
    
    
    func toShoppinglist() {
        
        let vm = ShoppinglistVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let scene: Scene = .ingredient(scene: .shoppinglist(vm))
        
        
        self.sceneCoodinator.transition(to: scene, type: .push)
        
    }
    
    func toContactForm() {
        
        let scene: Scene = .webSite(scene: .contact)
        self.sceneCoodinator.transition(to: scene, type: .web)
        
        
    }
    
    func toAboutPage() {
        
        let scene: Scene = .webSite(scene: .termsOfUseAndPrivacyPolicy)
        
        self.sceneCoodinator.transition(to: scene, type: .web)
        
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
            let scene: Scene = .loadingScene(scene: .loading(vm))
            self.sceneCoodinator.transition(to: scene, type: .root)
            
        } catch let signOutError as NSError {
            
            print("Error signing out: %@", signOutError)
            
            if let reason = signOutError.handleAuthenticationError() {
                reason.generateErrAlert()
            }
            
    
        }
        
        
    }
}

extension DiscoveryVM: SelectDegitalContentDelegate {
    
    func selectedImage(imageData: Data) {
        
    }
    
    func selectedImage(asset: PHAsset, kind: DigitalContentsFor, sceneCoordinator: SceneCoordinator) {
        
        let vm = SelectedImageVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: kind, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedImage(vm))
        
//        self.sceneCoodinator.modalTransition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: false))

        
        self.sceneCoodinator.transition(to: scene, type: .push)

    }
    
    func selectedVideo(asset: PHAsset) {
        
        let vm = SelectedVideoVM(sceneCoodinator: self.sceneCoodinator, user: self.user, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedVideo(vm))
        
//        self.sceneCoodinator.modalTransition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: false))

        self.sceneCoodinator.transition(to: scene, type: .push)
        
    }
    
    
    
}
