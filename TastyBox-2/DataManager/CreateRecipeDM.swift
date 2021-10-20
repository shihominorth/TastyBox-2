//
//  CreateRecipeDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-20.
//

import Foundation
import AVFoundation
import RxSwift

protocol CreateRecipeDMProtocol: AnyObject {
    static func getThumbnailData(url: URL) -> Observable<Data>
}

class CreateRecipeDM: CreateRecipeDMProtocol {
    
    
    static func getThumbnailData(url: URL) -> Observable<Data> {
        
        return Observable.create { observer in
            
            let asset: AVAsset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            
            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                
                if let data = thumbnailImage.data {
                    observer.onNext(data)
                }
                
            } catch (let err) {
                observer.onError(err)
            }
            
            return Disposables.create()
            
        }
    }
    
}
