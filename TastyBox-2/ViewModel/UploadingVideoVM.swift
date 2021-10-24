//
//  UploadingVIdeoVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-18.
//

import Foundation
import Firebase
import RxSwift
import RxRelay

protocol UploadingVideoVMDelegate: AnyObject {
    func addVideo(isAdded: Bool)
}

class UploadingVideoVM: ViewModelBase {
        
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    var urlSubject: Observable<URL>!
    var isHiddenPlayingViewRelay = PublishRelay<Bool>()
       
    weak var delegate: UploadingVideoVMDelegate?
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, url: URL) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        
        super.init()
        
        self.urlSubject = observeUrl(url: url)
        
    }
    
    func observeUrl(url: URL) -> Observable<URL> {
        
        return Observable.create { observer in
            
            observer.onNext(url)
            
            return Disposables.create()
            
        }
    }
    
    func addVideo() {
        
        self.sceneCoodinator.pop(animated: true)
        self.delegate?.addVideo(isAdded: true)
        
    }
    
    func back() {
        
        self.sceneCoodinator.pop(animated: true)
        self.delegate?.addVideo(isAdded: false)
    }
    
  
}