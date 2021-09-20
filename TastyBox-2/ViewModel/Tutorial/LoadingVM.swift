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
                    self.sceneCoodinator.transition(to: firstScene, type: .usePresentNC)
                    
                } else {
                    
                    let viewModel = DiscoveryVM(sceneCoodinator: self.sceneCoodinator, user: user)
                    let vc = MainScene.discovery(viewModel).viewController()
                    self.sceneCoodinator.transition(to: vc, type: .root)
                    
                }
                
            }, onFailure: { err in
                
                print(err as NSError)
                
                guard let reason = err.handleAuthenticationError() else { return }
                SCLAlertView().showTitle(
                    reason.reason, // Title of view
                    subTitle: reason.solution,
                    timeout: .none, // String of view
                    completeText: "Done", // Optional button value, default: ""
                    style: .error, // Styles - see below.
                    colorStyle: 0xA429FF,
                    colorTextButton: 0xFFFFFF
                )
            })
            
            
        }
        // not login yet.
        else {
            
           
            let viewModel = LoginMainVM(sceneCoodinator: sceneCoodinator)
            
            let firstScene = LoginScene.main(viewModel).viewController()
            sceneCoodinator.transition(to: firstScene, type: .root)
            
        }
    }
    
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
