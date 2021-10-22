//
//  CreateRecipeDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-20.
//

import Foundation
import AVFoundation
import Firebase
import RxSwift

protocol CreateRecipeDMProtocol: AnyObject {
    static func getThumbnailData(url: URL) -> Observable<Data>
    static func getGenres(user: Firebase.User) -> Observable<[Genre]>
}

class CreateRecipeDM: CreateRecipeDMProtocol {
    
    static let db = Firestore.firestore()
    
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
    
    
    static func getGenres(user: Firebase.User) -> Observable<[Genre]> {
        
        return Observable.create { observer in
            
            db.collection("users").document(user.uid).collection("genres")
                .addSnapshotListener { snapShot, err in
                    
                    if let err = err {
                        observer.onError(err)
                    }
                    else {
                        
                        if let docs = snapShot?.documents {
                            
                            let genres = docs.compactMap { doc -> Genre? in
                                
                                if let genre = Genre(document: doc) {
                                    return genre
                                }
                                else {
                                    return nil
                                }
                            }
                            
                            observer.onNext(genres)
                        }
                    }
                }
            
            return Disposables.create()
            
        }
    }
//    
//    func labelingImage(data: Data) {
//            
//        let options = VisionObjectDetectorOptions()
//    
//        let visionImage = VisionImage(data: data)
//        visionImage.orientation = image.imageOrientation
//        let labeler = ImageLabeler.imageLabeler(options: options)
//
//            labeler.process(image) { labels, error in
//                
//                guard error == nil else {
//                    print(error!)
//                    return
//                    
//                }
//                guard let labels = labels else { return }
//
//                // Task succeeded.
//                // ...
//                for (index, label) in labels.enumerated() {
//                    let labelText = label.text
//                   
//                    if labelText == "Cuisine" || labelText == "Food" || labelText == "Recipe" || labelText == "Cooking" || labelText == "Dish" || labelText == "Ingredient" {
//                      
//                        
//                    } else {
//                        self.labels.append(labelText)
//                    }
//                    
//                    if index == labels.count - 1 {
//                        print(self.labels)
//                        self.delegate?.passLabeledArray(arr: self.labels)
//                    }
//                }
//            }
//        }
}
