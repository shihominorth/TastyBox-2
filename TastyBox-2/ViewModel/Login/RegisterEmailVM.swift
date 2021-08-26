//
//  RegisterEmailVM.swift
//  Recipe-CICCC
//
//  Created by 北島　志帆美 on 2021-08-21.
//  Copyright © 2021 Shihomi Kitajima. All rights reserved.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class RegisterEmailVM {
    
    private let bag = DisposeBag()
    
    let apiType: RegisterAccountProtocol.Type
    
    var isRegistered: Single<Bool>?
    
    init(apiType: RegisterAccountProtocol.Type = RegisterAccountDM.self) {
        self.apiType = apiType
    }
    
    func registerEmail(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        
        isRegistered = self.apiType.registerEmail(email: email, password: password).asSingle()
        
    }
}
