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
    static func getUserImage(user: Firebase.User) -> Observable<Data> 
    static func userRegister(userName: String?, email: String?, familySize: String?, cuisineType: String?, accountImage: Data?) -> Observable<Void>
}

class RegisterMyInfoDM: RegisterMyInfoProtocol {
    
    static func getUserImage(user: Firebase.User) -> Observable<Data> {
        
        return Observable.create { observer in
            
            Storage.storage().reference().child("users/\(user.uid)/userImage").downloadURL { url, err in
            
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
        
        
        return Observable.create { observer in
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return Disposables.create()
            }
            guard let userName = userName else {
                return Disposables.create()
            }
            guard let email = email else {
                return Disposables.create()
            }
            guard let familySize = familySize?.convertToInt() else {
                return Disposables.create()
            }
            guard let cuisineType = cuisineType else {
                return Disposables.create()
            }
 
            guard let myImage = accountImage else {
                return Disposables.create()
            }

            Firestore.firestore().collection("users").document(uid).setData([
                
                "id": uid,
                "userName": userName,
                "eMailAddress": email,
                "familySize": familySize,
                "cuisineType": cuisineType,
                "isVIP": false,
                "isFirst": false
                
            ], merge: true) { err in
                
                if let err = err {
                   
                    observer.onError(err)
                    
                } else {
                    
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpg"
                    
                    Storage.storage().reference().child("users/\(uid)/userImage").putData(myImage, metadata: metaData) { metaData, err in
                        
                        if let err = err {
                            
                            observer.onError(err)
                       
                        }
                        else if metaData != nil {
                            
                            guard let _ = Auth.auth().currentUser?.displayName else {
                                
                                guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else {
                                    return
                                }
                                
                                changeRequest.displayName = userName
                                
                                changeRequest.commitChanges { err in
                                    
                                    if let err = err {
                                        
                                        observer.onError(err)

                                    } else {
                                        
                                        observer.onNext(())
                                    
                                    }
                                }
                                return
                            }
  
                            observer.onNext(())
                        }
                    }
                    
                }
                
                
                
            }
            
            
            return Disposables.create()
        }
    }
}
