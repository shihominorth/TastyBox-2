//
//  ReportDM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-11.
//

import Foundation
import Alamofire
import Firebase
import GoogleSignIn
import GoogleAPIClientForREST
import RxSwift


protocol ReportProtocol: AnyObject {
    
    static var gasService: GASService { get }
    static var firestoreService: FireStoreServices { get }
    static func report(kind: ReportKind, contentID: String, reason: ReportReason) -> Observable<Bool>

}

class ReportDM: ReportProtocol {

    static let db = Firestore.firestore()
    
    static var firestoreService: FireStoreServices {
        return FireStoreServices()
    }
    
    static var gasService: GASService {
        return GASService()
    }
    
    static func report(kind: ReportKind, contentID: String, reason: ReportReason) -> Observable<Bool> {

        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")

        let data = createData(kind: kind, contentID: contentID, reason: reason, id: uniqueIdString)

        let path = db.collection("reports").document(uniqueIdString)
        
        return firestoreService.setData(path: path, data: data)
            .catch({ err in
                
                err.handleFireStoreError()?.showErrNotification()
                
                print(err)
                
                return .empty()
            })
            .flatMapLatest { data in
                writeSpreadSheet(data: data)
            }
         
    
    }
    
    static func createData(kind: ReportKind, contentID: String, reason: ReportReason, id: String) -> [String: Any] {
 
        let createdDate = NSDate().description
                
        let data:[String: Any] = [
            
            "id": id,
            "kind": kind.rawValue,
            "contentID": contentID,
            "reportedDate": createdDate,
            "reason": reason.rawValue,
            "isSolved": false
            
        ]
        
        return data
    }
    
    static func writeSpreadSheet(data: [String: Any]) -> Observable<Bool> {
        
        let parameters: Parameters = ["kind": "recipe", "report": data]
        
        return gasService.post(parameters: parameters)
            .catch({ err in
                
                err.handleFireStoreError()?.showErrNotification()
                
                print(err)
                
                return .empty()

            }).map { _ in true }

    }
    
}
