//
//  StorageService.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-27.
//

import Foundation
import Firebase
import RxSwift

final class StorageService {
    
    func addImage(path: StorageReference, url: URL) -> Observable<URL> {
        
       
        return .create { observer in
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let uploadTask = path.putFile(from: url)
           
            // Listen for state changes, errors, and completion of the upload.
            uploadTask.observe(.resume) { snapshot in
                // Upload resumed, also fires when the upload starts
                print("resume")
            }
            
            uploadTask.observe(.pause) { snapshot in
                // Upload paused
                print("pause")
            }
            
            uploadTask.observe(.progress) { snapshot in
                // Upload reported progress
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
                
                print(percentComplete)
            }
            
            uploadTask.observe(.success) { snapShot in
                
                observer.onNext(url)
                
            }
            
            
            uploadTask.observe(.failure) { snapshot in
                
                if let err = snapshot.error {
                    
                    observer.onError(err)
                    
                }
            }
            
            return Disposables.create()
        }
      
        
    }
    
    func downLoadUrl(path: StorageReference) -> Observable<String> {
        
        return .create { observer in
            
            path.downloadURL { url, err in
                
                if let err = err {
                    observer.onError(err)
                }
                else {
                   
                    if let stringUrl = url?.absoluteString {
                        observer.onNext(stringUrl)
                    }
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    func downloadData(path: StorageReference) -> Observable<Data> {
        
        return .create { observer in
            
            path.getData(maxSize: 1 * 1024 * 1024) { data, err in
               
                if let err = err {
                 
                    observer.onError(err)
                    
                } else {
                 
                    if let data = data {
                        
                        observer.onNext(data)
                    
                    }
                    
                }
                
              }
                  
            
            return Disposables.create()
        }
        
    }
}
