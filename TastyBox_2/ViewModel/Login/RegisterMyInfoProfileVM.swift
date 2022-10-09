//
//  RegisterUserProfileVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//
import Action
import FBSDKLoginKit
import Firebase
import Foundation
import RxSwift
import RxCocoa
import RxRelay
import SCLAlertView

final class RegisterMyInfoProfileVM: ViewModelBase {
    
    private let apiType: RegisterMyInfoProtocol.Type
    private let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let defaultUserImageData =  #imageLiteral(resourceName: "defaultUserImage")
    var userImageSubject: BehaviorSubject<URL>!
    var isEnableDone = BehaviorRelay(value: false)
    var observeTxtFields = BehaviorRelay<String>(value: "")
    
    var userName = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    var familySize = BehaviorRelay<String>(value: "")
    var cuisineType = BehaviorRelay<String>(value: "")
    
    let photoPickerSubject: PublishSubject<Data>
    
    let cuisineTypeOptions: [String]
    let familySizeOptions: [String]
    
    
    init(sceneCoodinator: SceneCoordinator, apiType: RegisterMyInfoProtocol.Type = RegisterMyInfoDM.self, user:  Firebase.User) {
        
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        
        self.user = user
        
        self.photoPickerSubject = PublishSubject<Data>()
        self.userImageSubject = BehaviorSubject<URL>(value: URL(fileURLWithPath: ""))
        
        cuisineTypeOptions = ["Chinese Food", "Japanese Food", "Thai food"]
        familySizeOptions = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]
        
        guard let displayName = user.displayName, let userEmail = user.email else { return }
        
        
        userName.accept(displayName)
        email.accept(userEmail)
                
    }
    
    func getUserImage() -> Observable<URL> {
        
        return self.apiType.getUserImage(user: self.user)
            .catch { err in
                
                if let userImageURL = self.user.photoURL {
                    return Observable.just(userImageURL)
                }
                return .empty()
            }
    }
    
    func toPickPhoto() {
        
        let scene: Scene = .digitalContentsPickerScene(scene: .photo)
        
        self.sceneCoodinator.transition(to: scene, type: .photoPick(completion: { data in
            
//            self.userImageSubject.onNext(data)
            
        }))
        
    }
    
    func toCamera() {
        
        let scene: Scene = .digitalContentsPickerScene(scene: .camera)
        
        self.sceneCoodinator.transition(to: scene, type: .camera(completion: { data in
            
//            self.userImageSubject.onNext(data)
            
        }))
        
    }
    
    func registerUser() -> Observable<Void> {
        
        return Observable.combineLatest(userName, email, familySize, cuisineType)
            .flatMap { [unowned self] (name, email, familySize, cuisineType)  in
                
                self.apiType.userRegister(userName: name, email: email, familySize: familySize, cuisineType: cuisineType, accountImage: Data())
            }
            .catch { err in
                
                print(err)
                
                err.handleFireStoreError()?.showErrNotification()
                
                return .empty()
            }
        
    }
    
    func goToNext() {
        
        let vm = DiscoveryViewModel(sceneCoodinator: self.sceneCoodinator, user: self.user)
        let scene: Scene = .discovery(scene: .main(vm))
        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .crossDissolve, hasNavigationController: true))
        
    }
    
    func switchAccount() {
        
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
