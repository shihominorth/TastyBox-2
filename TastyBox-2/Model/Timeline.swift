//
//  Timeline.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import Foundation
import DifferenceKit

enum Timeline {
   
    case recipe(id: String, upateDate: Date, recipe: Recipe, publisher: User) //, case recipe(recipe: Recipe, publisher: User, comment: String)
    
    var id: String {
        switch self {
        case let .recipe(id, _, _, _):
            return id
        }
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
