//
//  Ingredient.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import DifferenceKit
import Firebase

class Ingredient  {
    
    var key: String
    var name: String
    var amount: String
    var order: Int
    
    init(key: String, name: String, amount: String, order: Int) {
        self.key = key
        self.name = name
        self.amount = amount
        self.order = order
    }
}


extension Ingredient: Hashable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        //同じインスタンスを参照していれば、`==`であると定義する場合
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
    //アドレスそのものが「等しいかどうか」の判定に使われているので、`ObjectIdentifier(self)`に対して`hash(into:)`を呼んでやる
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

class ShoppingItem: Ingredient {
    
    var isBought: Bool
 
    init(name: String, amount: String, key: String, isBought: Bool, order: Int) {
      
        self.isBought = isBought
        super.init(key: key, name: name, amount: amount, order: order)
    }

    init?(document:  QueryDocumentSnapshot) {
        
        let value = document.data()
        
        guard
            let name = value["name"] as? String,
            let amount = value["amount"] as? String,
            let isBought  = value["isBought"] as? Bool,
            let order = value["order"] as? Int
            else {
                return nil
        }
        
        self.isBought = isBought
        super.init(key: document.documentID, name: name, amount: amount, order: order)
    }
}

class RefrigeratorItem: Ingredient {
    
    override init(key: String, name: String, amount: String, order: Int) {
        super.init(key: key, name: name, amount: amount, order: order)
    }
    
    init?(document:  QueryDocumentSnapshot) {
        
        let value = document.data()
        
        guard
            let name = value["name"] as? String,
            let amount = value["amount"] as? String,
            let order = value["order"] as? Int
            else {
                return nil
        }
        
        super.init(key: document.documentID, name: name, amount: amount, order: order)
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

struct DeletingIngredient {
    var index: Int
    var item: Ingredient
    
}
