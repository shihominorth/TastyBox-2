//
//  RegisterMyInfoDataManager.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation
import Firebase
import RxSwift

class RegisterMyInfoDataManager {
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    // account image should convert from uiimage to data?
    // in order to convert it, use .jpegData() before call userRegister.
    
    func userRegister(userName: String, email: String, familySize: Int, cuisineType: String, accountImage: Data?, isVIP: Bool) -> Observable<Bool>{
        
        
        return Observable.create { observer in
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return Disposables.create()
            }
            
//            guard let myImage = accountImage else {
//                return Disposables.create()
//            }
            
            self.db.collection("user").document(uid).setData([
                
                "id": uid,
                "userName": userName,
                "eMailAddress": email,
                "familySize": familySize,
                "cuisineType": cuisineType,
                "isVIP": isVIP,
                "isFirst": false
                
            ], merge: true) { err in
                if let err = err {
                    observer.onError(err)
                   
                } else {
                    observer.onNext(true)
                    print("Document successfully written!")
                }
            }
//
//                    guard let imgData = accountImage.jpegData(compressionQuality: 0.75) else{ return }
//                    let metaData = StorageMetadata()
//                    metaData.contentType = "image/jpg"
            
//                    storageRef.child("user/\(uid)/userAccountImage").putData(imgData, metadata: metaData){ (metaData, error) in
//                        if error == nil, metaData != nil{
//                            print("success")
//            
//                        }else{
//                            print("error in save image")
//                        }
//                    }
            
            return Disposables.create()
        }
    }
}
