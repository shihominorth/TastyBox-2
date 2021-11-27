//
//  StorageService.swift.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-27.
//

import Foundation
import Firebase
import RxSwift

class StorageService {
    
  
    
    required init() {
        
       
        
    }
    
    func addImage(path: StorageReference, image: Data) -> Observable<Data> {
        
       
        return .create { observer in
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let uploadTask = path.putData(image, metadata: metaData)
           
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
                
                observer.onNext(image)
                
            }
            
            
            uploadTask.observe(.failure) { snapshot in
                
                if let err = snapshot.error {
                    
                    observer.onError(err)
                    
                }
            }
            
            return Disposables.create()
        }
      
        
    }
}
