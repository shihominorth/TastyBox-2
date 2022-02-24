//
//  RegisterMyInfoDataManager.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

protocol RegisterMyInfoProtocol: AnyObject {
    static var firestoreService: FirestoreServices { get }
    static var storageService: StorageService { get }
    static func getUserImage(user: Firebase.User) -> Observable<Data>
    static func userRegister(userName: String?, email: String?, familySize: String?, cuisineType: String?, accountImage: Data?) -> Observable<Void>
}

final class RegisterMyInfoDM: RegisterMyInfoProtocol {
    
    static var firestoreService: FirestoreServices {
        return FirestoreServices()
    }
    
    static var storageService: StorageService {
        return StorageService()
    }
    
    static func getUserImage(user: Firebase.User) -> Observable<Data> {
        
        return Observable.create { observer in
            
            Storage.storage().reference().child("users/\(user.uid)/userImage.jpg").downloadURL { url, err in
                
                if let err = err {
                    observer.onError(err)
                }
                else if let url = url {
                    
                    guard let data = try? Data(contentsOf: url) else {
                        return
                    }
                    
                    observer.onNext(data)
                    
                }
                
            }
            
            
            return Disposables.create()
        }
    }
    
    
    
    
    // account image should convert from uiimage to data?
    // in order to convert it, use .defineUserImage() before call userRegister.
    
    // observer or maybe are the best because the functions for firebase is nested.
    
    static func userRegister(userName: String?, email: String?, familySize: String?, cuisineType: String?, accountImage: Data?) -> Observable<Void> {
        
        if let uid = Auth.auth().currentUser?.uid, let userName = userName, let email = email, let familySize = familySize?.convertToInt(), let cuisineType = cuisineType,  let myImage = accountImage {
            
            let path = Firestore.firestore().collection("users").document(uid)
            let imagePath =  Storage.storage().reference().child("users/\(uid)/userImage.jpg")
            
            return firestoreService.setData(path: path, data: [
                
                "id": uid,
                "userName": userName,
                "eMailAddress": email,
                "familySize": familySize,
                "cuisineType": cuisineType,
                "isVIP": false,
                "isFirst": false
                
            ])
                .flatMapLatest { _ in
                    self.storageService.addImage(path: imagePath, image: myImage)
                }
                .flatMapLatest({ _ in
                    self.storageService.downLoadUrl(path: imagePath)
                })
                .flatMapLatest({ url -> Observable<[String: Any]> in
                    let data = [ "imgString": url]
                    return self.firestoreService.updateData(path: path, data: data)
                })
                .flatMapLatest { _ in
                    self.changeDisplayName(userName: userName)
                }
//                .map { _ in }
        }
        
        return Observable<Void>.just(())
    }
    
    static func changeDisplayName(userName: String) -> Observable<Void> {
        
        return .create { observer in
            
            if let displayName = Auth.auth().currentUser?.displayName {
                
                if userName == displayName {
                    
                    observer.onNext(())
                    
                }
                else {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        
                        changeRequest.displayName = userName
                        
                        changeRequest.commitChanges { err in
                            
                            if let err = err {
                                
                                observer.onError(err)
                                
                            } else {
                                
                                observer.onNext(())
                                
                            }
                        }
                        
                    }
                   
                    
                }
                
               
            }
            else {
                
                observer.onNext(())
            
            }
           
            return Disposables.create()
        }
        
        
    }
}
