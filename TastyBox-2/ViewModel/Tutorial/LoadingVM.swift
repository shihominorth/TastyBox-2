//
//  LoadingVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-19.
//

import Foundation
import Firebase
import RxSwift
import SCLAlertView

class LoadingVM {
    
    let sceneCoodinator: SceneCoordinator
    let apiType: LoginMainProtocol.Type
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
    }
    
    func goToNextVC() {
        
        // login already
        if let user = Auth.auth().currentUser {
            
            let _ = isRegisteredMyInfo(user: user).subscribe(onSuccess: { isFirst in
                
                if isFirst {
                    
                    let viewModel = RegisterMyInfoProfileVM(sceneCoodinator: self.sceneCoodinator, user: user)
                    let firstScene = LoginScene.profileRegister(viewModel).viewController()
                    
                    self.sceneCoodinator.transition(to: firstScene, type: .push)
                    
                } else {
                    
                    let viewModel = DiscoveryVM(sceneCoodinator: self.sceneCoodinator, user: user)
                    let vc = DiscoveryScene.discovery(viewModel).viewController()
                    
                    self.sceneCoodinator.transition(to: vc, type: .root)
                    
                }
                
            }, onFailure: { err in
                
                print(err)
                err.handleAuthenticationError()?.showErrNotification()
                
            })
            
            
        }
        // not login yet.
        else {
            
            let defaults = UserDefaults.standard
            
            if defaults.bool(forKey: "isTutorialDone") {
               
                
                let vm = LoginMainVM(sceneCoodinator: sceneCoodinator)
                let firstScene: Scene = .loginScene(scene: .main(vm))
                
                sceneCoodinator.modalTransition(to: firstScene, type: .push)
                
                
            } else {
                
                // First start after installing the app
                let vm = TutorialVM(sceneCoodinator: self.sceneCoodinator)
                let scene: Scene = .loginScene(scene: .tutorial(vm))
                
//                self.sceneCoodinator.modalTransition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .crossDissolve, hasNavigationController: false))
                self.sceneCoodinator.modalTransition(to: scene, type: .push)
           
//                defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
//                print("App launched first time")
                
            
            }
//
//            UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
//            UserDefaults.standard.synchronize()
            
            
        }
    }
    
//    func isTutorialDone(user: Firebase.User) -> Observable<Bool> {
//
//        return self.apiType.isTutorialDone(user: user)
//
//    }
    
    func isRegisteredMyInfo(user: FirebaseAuth.User) -> Single<Bool> {
        
        return Single.create { single in
            
            Firestore.firestore().collection("users").document(user.uid).addSnapshotListener { data, err in
                
                if let err = err {
                    single(.failure(err))
                } else {
                    
                    guard let data = data else { return }
                    guard let isFirst = data.get("isFirst") as? Bool else {
                        
                        single(.success(true))
                        return
                        
                    }
                    
                    single(.success(isFirst))
                    
                }
                
            }
            
            return Disposables.create()
        }
    }
}
