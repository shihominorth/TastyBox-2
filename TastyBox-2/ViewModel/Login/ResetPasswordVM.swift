//
//  ResetPasswordVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Action
import Foundation
import RxSwift
import RxRelay
import SCLAlertView

final class ResetPasswordVM: ViewModelBase {
    
    let dataManager = ResetPasswordDM()
   private let apiType: ResetPasswordProtocol.Type
    let cancelAction: CocoaAction
    
    init(coordinator: SceneCoordinator, cancelAction: CocoaAction? = nil, apiType: ResetPasswordProtocol.Type = ResetPasswordDM.self) {
        
        self.apiType = apiType
        
        self.cancelAction = CocoaAction {

            if let cancelAction = cancelAction {
                cancelAction.execute(())
            }
            return coordinator.pop()
                .asObservable()
                .map { _ in }
        }
    }
    
  
    lazy var resetPasswordAction: Action<String, Swift.Never> = { this in
       
        return Action { email in
            
            return Observable.create { observer in
               
               let _ = self.apiType.resetPassword(email: email)
                    .subscribe(onCompleted: {
                        
                        SCLAlertView().showTitle(
                            "Check your email", // Title of view
                            subTitle: "We sent the email that can reset password to you.",
                            timeout: .none, // String of view
                            completeText: "Done", // Optional button value, default: ""
                            style: .notice, // Styles - see below.
                            colorStyle: 0xA429FF,
                            colorTextButton: 0xFFFFFF
                        )
                        
                        
                    }, onError: {  err in
                        
                        guard let reason = err.handleAuthenticationError() else {
                            
                            SCLAlertView().showTitle(
                                "Error", // Title of view
                                subTitle: "You can't login.",
                                timeout: .none, // String of view
                                completeText: "Done", // Optional button value, default: ""
                                style: .error, // Styles - see below.
                                colorStyle: 0xA429FF,
                                colorTextButton: 0xFFFFFF
                            )
                            return
                            
                        }
                        
                        SCLAlertView().showTitle(
                            reason.reason, // Title of view
                            subTitle: reason.solution,
                            timeout: .none, // String of view
                            completeText: "Done", // Optional button value, default: ""
                            style: .error, // Styles - see below.
                            colorStyle: 0xA429FF,
                            colorTextButton: 0xFFFFFF
                        )}
                    )
                
                return Disposables.create ()
            }
        }
        
    }(self)
    
}
