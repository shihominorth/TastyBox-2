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
    
    func setData(references: [DocumentReference], dic: [String: Any]) -> Observable<Void> {

        return .create { observer in
            
            var count = 0
            
            references.forEach { reference in
                
                
                self.setData(reference: reference, data: dic, isMerge: true, completion: { data in

                    count += 1
                    
                    if count == references.count {
                        
                        observer.onNext(())
                        
                    }
                    
                }, errBlock: { err in
                    
                    print(err)
                    
                    count += 1
                    
                    if count == references.count {
                        
                        observer.onNext(())
                        
                    }
                    
                    
                })
                
            }
            
            
            return Disposables.create()
        }
        
    }
    
    func setData(reference: DocumentReference, data: [String: Any], isMerge: Bool = true, completion: @escaping ([String: Any]) -> Void, errBlock: @escaping (Error) -> Void) {
 
            reference.setData(data, merge: isMerge) { err in
                
                if let err = err {
                    
                   errBlock(err)
                    
                }
                else {
                    
                    completion(data)
                    
                }
                
            
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
    
    func getDocuments(query: Query) -> Observable<[QueryDocumentSnapshot]> {
        
        return .create { observer in
            
            query.getDocuments { snapShot, err in
                if let err = err {
                    
                    observer.onError(err)
                    
                }
                else {
                    
                    if let docs = snapShot?.documents {
                        observer.onNext(docs)
                    }
                   
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    func updateData(references: [DocumentReference], dic: [String: Any]) -> Observable<Void> {

        return .create { observer in
            
            var count = 0
            
            references.forEach { reference in
                
                
                self.updateData(reference: reference, data: dic, completion: { data in

                    count += 1
                    
                    if count == references.count {
                        
                        observer.onNext(())
                        
                    }
                    
                }, errBlock: { err in
                    
                    print(err)
                    
                    count += 1
                    
                    if count == references.count {
                        
                        observer.onNext(())
                        
                    }
                    
                    
                })
                
            }
            
            
            return Disposables.create()
        }
        
    }
    
    func updateData(reference: DocumentReference, data: [String: Any], completion: @escaping ([String: Any]) -> Void, errBlock: @escaping (Error) -> Void) {
 
            reference.updateData(data) { err in
                
                if let err = err {
                    
                   errBlock(err)
                    
                }
                else {
                    
                    completion(data)
                    
                }
                
            
        }
    }
    
}
