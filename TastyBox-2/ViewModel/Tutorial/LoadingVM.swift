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

final class LoadingVM: ViewModelBase {
    
    private let sceneCoodinator: SceneCoordinator
    private let apiType: LoginMainProtocol.Type
    
    init(sceneCoodinator: SceneCoordinator, apiType: LoginMainProtocol.Type = LoginMainDM.self) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
    }
    
    func goToNextVC() {
        
        // login already
        
        if let user = Auth.auth().currentUser {
        
            self.apiType.isRegisteredMyInfo
                .retry(3)
                .catch { err in
                    
                    err.handleFireStoreError()?.generateErrAlert()
                    
                    return .empty()
                    
                }
                .subscribe(onNext: { isFirst in
                
                if isFirst {
                    
                    let vm = RegisterMyInfoProfileVM(sceneCoodinator: self.sceneCoodinator, user: user)
                    let firstScene: Scene = .loginScene(scene: .profileRegister(vm))
                    
                    self.sceneCoodinator.transition(to: firstScene, type: .push)
                    
                } else {
                    
                    let vm = DiscoveryViewModel(sceneCoodinator: self.sceneCoodinator, user: user)
                    let firstScene: Scene = .discovery(scene: .main(vm))
                    
                    self.sceneCoodinator.transition(to: firstScene, type: .root)
                    
                }
                
            }).disposed(by: disposeBag)
            
            
        }
        // not login yet.
        else {
            
            let defaults = UserDefaults.standard
            
            if defaults.bool(forKey: "isTutorialDone") {
               
                
                let vm = LoginMainVM(sceneCoodinator: sceneCoodinator)
                let scene: Scene = .loginScene(scene: .main(vm))
                
//                sceneCoodinator.modalTransition(to: firstScene, type: .push)
                self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .crossDissolve, hasNavigationController: true))

                
            } else {
                
                // First start after installing the appr
                let vm = TutorialVM(sceneCoodinator: self.sceneCoodinator)
                let scene: Scene = .loginScene(scene: .tutorial(vm))
                
//                self.sceneCoodinator.modalTransition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .crossDissolve, hasNavigationController: false))
                self.sceneCoodinator.transition(to: scene, type: .push)

                
            }

        }
    }
    
//    func isTutorialDone(user: Firebase.User) -> Observable<Bool> {
//
//        return self.apiType.isTutorialDone(user: user)
//
//    }
    
}
