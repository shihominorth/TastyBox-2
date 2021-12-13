//
//  SelectDigitalContentsVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-13.
//

import Foundation
import Firebase
import Photos
import RxSwift

enum DigitalContentsFor {
    case profile, mainImg, mainVideo, instructionImg
}

protocol SelectDegitalContentDelegate: AnyObject {
    func selectedImage(image: Data)
    func selectedVideo(videoUrl: URL)
}

class SelectDigitalContentsVM: ViewModelBase {
    
    var assets = PHFetchResult<PHAsset>()

    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    let kind: DigitalContentsFor
  
    
    weak var delegate: SelectDegitalContentDelegate?
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, kind: DigitalContentsFor) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.kind = kind

        super.init()
 
    }
    
    func fetchContents(kind: DigitalContentsFor) {

        switch kind {
        
        case .profile, .mainImg, .instructionImg:
            
            assets = PHAsset.fetchAssets(with: .image, options: nil)
      
        case .mainVideo:
            
            assets = PHAsset.fetchAssets(with: .video, options: nil)
      
        }
 
     
        
    }
  
}
