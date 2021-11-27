//
//  FireStoreServices.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-26.
//

import Foundation
import Firebase
import RxSwift

class FireStoreServices {
    
    let db: Firestore
    
    required init() {
        
        db = Firestore.firestore()
        
    }
    
    func setData(path: DocumentReference, data: [String: Any], isEnableMerge: Bool = true) -> Observable<[String: Any]> {
        
        return .create { observer in
            
            path.setData(data, merge: isEnableMerge) { err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    observer.onNext(data)
                    
                }
                
            }
            
            return Disposables.create()
            
        }
        
    }
    
    func updateData(path: DocumentReference, data: [String: Any]) -> Observable<[String: Any]>  {
        
        return .create { observer in
            
            path.updateData(data) { err in
                
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    observer.onNext(data)
                    
                }
                
            }
            
            return Disposables.create()
        }
        
        
        
    }
    
    func getDocument(path: DocumentReference) -> Observable<[String: Any]> {
        
        return .create { observer in
            
            path.getDocument { doc, err in
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    if let doc = doc, let data = doc.data() {
                        observer.onNext(data)
                    }
                   
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    
}
