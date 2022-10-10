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
import RxCocoa
import RxSwift

protocol SelectDigitalDataDiscoveryViewModelDelegate: AnyObject {
    func selectedImage(asset: PHAsset, kind: DigitalContentsFor, sceneCoordinator: SceneCoordinator)
    func selectedVideo(asset: PHAsset)
}

protocol DiscoveryViewModelLike: AnyObject where Self: ViewModelBase {
    var isMenuBarOpenedRelay:  BehaviorRelay<Bool> { get set }
    var pages: [String] { get set }
    
    func setSideMenuTableViewToPresenter(tableView: SideMenuTableViewController)
    func setPageviewControllerToPresenter(pageViewController: UIPageViewController)
    func setDefaultViewControllers()
    func toCreateRecipeVC()
    func sideMenuTapped()
    func setIsMenuBarOpenedRelay() -> Observable<Bool>
    func selectPageTitle(row: Int)
}

final class DiscoveryViewModel: ViewModelBase, DiscoveryViewModelLike {

    private var navigator: DiscoveryNavigatorLike
    
    private let sceneCoodinator: SceneCoordinator
    private let user: Firebase.User
    
    //    let selectedIndexRelay: BehaviorRelay<Int>
    var isMenuBarOpenedRelay: BehaviorRelay<Bool>
    
    var selectedIndex: Int
    var pages: [String]
        
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, pages: [String] = ["Subscribed Creator",  "Your Ingredients Recipe", "Most Popular"]) {
        let navigator = DiscoveryNavigator(user: user, sceneCoordinator: sceneCoodinator)
        self.navigator = navigator
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.isMenuBarOpenedRelay = BehaviorRelay<Bool>(value: false)
        self.selectedIndex = 1
        
        self.pages = pages
    }
    
    func setDefaultViewControllers() {
        navigator.setDefaultViewController()
    }
    
    func setSideMenuTableViewToPresenter(tableView: SideMenuTableViewController) {
        self.navigator.sideMenuViewController = tableView
    }
    
    func setPageviewControllerToPresenter(pageViewController: UIPageViewController) {
        self.navigator.pageViewController = pageViewController
    }
    
    func sideMenuTapped() {
        self.navigator.sideMenuViewController?.tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                navigator.sideMenuViewController?.tableView.deselectRow(at: indexPath, animated: true)
                
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
        navigator.setViewControllers(row: row)
    }
    
    
    func toCreateRecipeVC() {
        let vm = SelectDigitalContentsVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: .recipeMain(.image), isEnableSelectOnlyOneDigitalContentType: false)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectDigitalContents(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: true))
    }
    
    private func toMyProfile() {
        let vm = MyProfileVM(sceneCoordinator: self.sceneCoodinator, user: self.user)
        
        self.sceneCoodinator.transition(to: .profileScene(scene: .myProfile(vm)), type: .push)
    }
    
    private func toRefrigerator() {
        let vm = RefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let scene: Scene = .ingredient(scene: .refrigerator(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .push)
    }
    
    
    private func toShoppinglist() {
        let vm = ShoppinglistVM(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let scene: Scene = .ingredient(scene: .shoppinglist(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .push)
    }
    
    private func toContactForm() {
        let scene: Scene = .webSite(scene: .contact)
        self.sceneCoodinator.transition(to: scene, type: .web)
    }
    
    private func toAboutPage() {
        let scene: Scene = .webSite(scene: .termsOfUseAndPrivacyPolicy)
        
        self.sceneCoodinator.transition(to: scene, type: .web)
    }
    
    private func logout() {
        
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

extension DiscoveryViewModel: SelectDigitalDataDiscoveryViewModelDelegate {
    func selectedImage(asset: PHAsset, kind: DigitalContentsFor, sceneCoordinator: SceneCoordinator) {
        let vm = SelectedImageVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: kind, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedImage(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .push)
        
    }
    
    func selectedVideo(asset: PHAsset) {
        let vm = SelectedVideoVM(sceneCoodinator: self.sceneCoodinator, user: self.user, asset: asset)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectedVideo(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .push)
    }
}
