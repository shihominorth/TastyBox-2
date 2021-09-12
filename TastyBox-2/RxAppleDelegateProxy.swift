//
//  RxAppleDelegateProxy.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-12.
//

import Foundation
import AuthenticationServices
import RxSwift
import RxCocoa

class RxAppleDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>, ASAuthorizationControllerDelegate  {
    
    public weak private(set) var controller: ASAuthorizationController?
    
    // 初期化処理
    public init(controller: ASAuthorizationController) {
        
        super.init(parentObject: controller, delegateProxy: RxAppleDelegateProxy.self)
        
    }
    
}

extension RxAppleDelegateProxy: DelegateProxyType {
    
    static func registerKnownImplementations() {
        
        register { controller in
            
            RxAppleDelegateProxy(controller: controller)
            
        }
    }
    
    static func currentDelegate(for object: ASAuthorizationController) -> ASAuthorizationControllerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ASAuthorizationControllerDelegate?, to object: ASAuthorizationController) {
        <#code#>
    }
}

extension Reactive where Base: ASAuthorizationController {
    public var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
        return self.delegate
    }
}
