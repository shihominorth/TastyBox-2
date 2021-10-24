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
    static func getMyGenresIDs(user: Firebase.User) -> Observable<[String]>
    static func getMyGenres(ids: [String], user: Firebase.User) -> Observable<([Genre], Bool)>
    static func createGenres(genres: [Genre], user: Firebase.User) -> Observable<([Genre], Bool)>
    
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
    
    static func getMyGenresIDs(user: Firebase.User) -> Observable<[String]> {
        
        return Observable.create { observer in
            
            db.collection("users").document(user.uid).collection("genres")
                .addSnapshotListener { snapShot, err in

                    if let err = err {

                        observer.onError(err)

                    }
                    else {

                        if let docs = snapShot?.documents {

                            let ids = docs.map { $0.documentID }
                            observer.onNext(ids)
                        }
                    }
                }
            
            return Disposables.create()
        }
    }
    
    
    static func getMyGenres(ids: [String], user: Firebase.User) -> Observable<([Genre], Bool)> {
        
        return .create { observer in
            
            var inplementCount = ids.count
            var genres:[Genre] = []

            ids.enumerated().forEach { index, id in

                db.collection("genres").whereField("id", isEqualTo: id).getDocuments { snapShot, err in

                    inplementCount -= 1
                    
                    if let err = err {

                        if inplementCount == 0 {

                            print(err)
                            observer.onNext((genres, true))

                        }
                        else {

                            observer.onError(err)
                        }

                    }
                    else {

                        if let doc = snapShot?.documents.first {

                            if let genre = Genre(document: doc) {

                                genres.append(genre)

                            }

                            if inplementCount == 0 {

                                observer.onNext((genres, true))

                            }
                            else {

                                observer.onNext((genres, false))
                            }

                        }

                    }

                }

            }
            
            return Disposables.create()
            
        }
    }
    
    
    static func createGenres(genres: [Genre], user: Firebase.User) -> Observable<([Genre], Bool)> {
        
        return .create { observer in
            
            genres.enumerated().forEach { index, genre in
                
                let data: [String : Any] = [
                    
                    "id": genre.id,
                    "title": genre.title,
                    "count": FieldValue.increment(Int64(1))
                ]
                
                
                db.collection("genres").document(genre.id).setData(data) { err in
                    
                    if let err = err {
                        
                        
                        if index == genres.count - 1 {
                            
                            print(err)
                            
                            observer.onNext((genres, true))
                            
                        }
                        else {
                            
                            observer.onError(err)
                        }
                        
                    }
                    else {
                        
                        db.collection("users").document(user.uid).collection("genres").document(genre.id).setData([
                            
                            "id": genre.id,
                            "usedLatestDate": Date(),
                            "count": FieldValue.increment(Int64(1))
                            
                        ]) { err in
                            
                            if let err = err {
                                
                                
                                if index == genres.count - 1 {
                                    
                                    print(err)
                                    
                                    observer.onNext((genres, true))
                                    
                                }
                                else {
                                    
                                    observer.onError(err)
                                }
                                
                            }
                            else {
                                
                                if index == genres.count - 1 {
                                    
                                    observer.onNext((genres, true))
                                    
                                }
                                else {
                                    
                                    observer.onNext((genres, false))
                                }
                            }
                        }
                        
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
