//
//  UploadingVIdeoVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-18.
//

import Foundation
import Firebase
import RxSwift

class UploadingVideoVM: ViewModelBase {
    
    var urlSubject = PublishSubject<URL>()
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, url: URL) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        
        self.urlSubject.onNext(url)
    }
}
