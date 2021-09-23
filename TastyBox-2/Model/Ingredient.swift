//
//  Ingredient.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import DifferenceKit
import Firebase

class Ingredient {
    var name: String
    var amount: String
    
    init(name: String, amount: String) {
        self.name = name
        self.amount = amount
    }
}

class ShoppingItem: Ingredient {
    
    var key: String
    var isBought: Bool
 
    init(name: String, amount: String, key: String, isBought: Bool) {
        self.key = key
        self.isBought = isBought
        super.init(name: name, amount: amount)
    }

    init?(document:  QueryDocumentSnapshot) {
        
        let value = document.data()
        
        guard
            let name = value["name"] as? String,
            let amount = value["amount"] as? String,
            let isBought  = value["isBought"] as? Bool
            else {
                return nil
        }
        
        self.key = document.documentID
        self.isBought = isBought
        super.init(name: name, amount: amount)
    }
}

class RefrigeratorItem: Ingredient {
    
    var key: String
 
    init(name: String, amount: String, key: String) {
        self.key = key
        super.init(name: name, amount: amount)
    }

    init?(document:  QueryDocumentSnapshot) {
        
        let value = document.data()
        
        guard
            let name = value["name"] as? String,
            let amount = value["amount"] as? String
            else {
                return nil
        }
        
        self.key = document.documentID
        super.init(name: name, amount: amount)
    }
}

extension RefrigeratorItem: Differentiable {
   
    var differenceIdentifier: String {
        return self.key
    }
    
    func isContentEqual(to source: RefrigeratorItem) -> Bool {
        return name == source.name
    }
    
  
}

extension ShoppingItem: Differentiable {
   
    var differenceIdentifier: String {
        return self.key
    }
    
    func isContentEqual(to source: ShoppingItem) -> Bool {
        return name == source.name
    }
    
  
}
