//
//  Timeline.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import Foundation
import DifferenceKit
import Firebase

enum Timeline {
   
    case recipe(id: String, upateDate: Date, recipeId: String, publisherId: String) //, case recipe(recipe: Recipe, publisher: User, comment: String)
    
    var id: String {
        switch self {
        case let .recipe(id, _, _, _):
            return id
        }
    }
    
    static func newTimeline(doc: DocumentSnapshot) -> Timeline? {
        
        if let data = doc.data(), let kind = data["kind"] as? String {
            
            switch kind {
            case "recipes":
                
                guard let id = data["id"] as? String, let updateDate = data["updateDate"] as? Timestamp, let publisherId = data["publisherId"] as? String, let recipeId = data["recipeId"] as? String else { return nil }
                
                return .recipe(id: id, upateDate: updateDate.dateValue(), recipeId: recipeId, publisherId: publisherId)
                
            default:
                break
            }
            
        }
        
        return nil
    }
}

extension Timeline: Differentiable {
    
    func isContentEqual(to source: Timeline) -> Bool {
        
        return id == source.id
        
    }
    
    var differenceIdentifier: String {
    
        return id
    
    }
}
