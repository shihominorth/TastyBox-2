//
//  SetPasswordVm.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-07.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class SetPasswordVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let apiType: RegisterAccountProtocol.Type
    let email: String
    let isMatchedTriger = PublishRelay<Bool>()
    
    init(email: String, apiType: RegisterAccountProtocol.Type = RegisterAccountDM.self, sceneCoordinator: SceneCoordinator) {
        self.apiType = apiType
        self.sceneCoordinator = sceneCoordinator
        self.email = email
    }
    
    lazy var signUpWithPasswordAction: Action<String, Swift.Never> = { this in
        
        
        return Action { password in
            
            
            print("\nsign up is processing....")
            
            
            return this.apiType.signUpWithPassword(email: this.email, password: password)
                .catch { err in
                    
                    print(err)
                    
                    return .empty()
                    
                }.asObservable()
        }
        
        
    }(self)
    
    func toLoginMainAction() ->  CocoaAction {
        
        return CocoaAction { _ in
            
            let vm = LoginMainVM(sceneCoodinator: self.sceneCoordinator)
            let vc = LoginScene.main(vm).viewController()
            
            return self.sceneCoordinator.transition(to: vc, type: .root)
                .asObservable().map { _ in }
            
        }
        
    }
    
    func aboutAction() -> CocoaAction {
      return CocoaAction { _ in
        
        let viewModel = AboutViewModel(sceneCoodinator: self.sceneCoordinator, prevVC: .registerEmail, isAgreed: false)
        let viewController = LoginScene.about(viewModel).viewController()
        
            return self.sceneCoordinator
                .transition(to: viewController, type: .push)
              .asObservable()
              .map { _ in }
        }
        
    }
    
}



