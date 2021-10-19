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


class UploadingVideoVM: ViewModelBase {
    
//    var url: URL!
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    var urlSubject: Observable<URL>!
    var isPlayingRelay = PublishSubject<PlayViewStatus>()
    var isHiddenPlayingViewRelay = PublishRelay<Bool>()
    var isHiddenSliderRelay = PublishRelay<Bool>()
    
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
    
    func observeIsPlaying(isPlaying: Bool) -> Observable<Bool> {
        
        return Observable.create { observer in
            
            observer.onNext(isPlaying)
            
            return Disposables.create()
            
        }
    }
    
    func setIsPlaying(status: PlayViewStatus) -> Observable<PlayViewStatus> {
        
        return Observable.create { [unowned self] observer in
        
            let changedStatus = PlayViewStatus.changeStatus(status: status)
            
            self.isPlayingRelay.onNext(changedStatus)
            observer.onNext(changedStatus)
        
            return Disposables.create()
        }
    }
    
    func addVideo() {
        
        self.sceneCoodinator.pop(animated: true)
        
    }
    
    func back() {
        
        self.sceneCoodinator.pop(animated: true)
        
    }
}
