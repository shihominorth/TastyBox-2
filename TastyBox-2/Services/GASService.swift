//
//  GASService.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-12.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON

enum GASServiceErr: Error {
    case noPostUrlRegistered
}

class GASService {
    
    func post(parameters: Parameters) -> Observable<JSON> {
        
        return .create { observer in
            
            let env = ProcessInfo.processInfo.environment
            if let postUrlString = env["reportPostUrl"], let url = URL(string: postUrlString) {
              
                AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .responseString { response in
                        
                        switch response.result {
                        case .success:
                            
                            let json = JSON(response.data as Any)
                            
                            print(json)
                            
                            observer.onNext(json)
                            
                        case .failure(let err):
                            
                            observer.onError(err)
                            

                        }
                        
                    }
                
            } else {
                
                observer.onError(GASServiceErr.noPostUrlRegistered)
                
            }

            return Disposables.create()
        }
        
    }
    
}
