//
//  Ingredient.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import DifferenceKit
import Firebase
import RxSwift

class Ingredient  {
    
    var id: String
    var name: String
    var amount: String
    var index: Int
    
    init(key: String, name: String, amount: String, order: Int) {
       
        self.id = key
        self.name = name
        self.amount = amount
        self.index = order
    
    }
    
    init?(queryDoc: QueryDocumentSnapshot) {
        
        let data = queryDoc.data()
        
        guard let id = data["id"] as? String,
              let index = data["index"] as? Int,
              let name = data["name"] as? String,
              let amount = data["amount"] as? String
        else { return nil }

        self.id = id
        self.index = index
        self.name = name
        self.amount = amount
        
    }
    
    
    static func generateNewIngredients(queryDocs: [QueryDocumentSnapshot]) -> Observable<[Ingredient]> {
        
        return .create { observer in
            
            let ingredients = queryDocs.compactMap { doc in

                return Ingredient(queryDoc: doc)

            }
            
            observer.onNext(ingredients)
            
            return Disposables.create()

        }
        
        
    }
}

extension Ingredient: Differentiable {
    
    
     var differenceIdentifier: String {
         return self.id
     }
     
     func isContentEqual(to source: ShoppingItem) -> Bool {
         return name == source.name
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
            let id = value["id"] as? String,
            let name = value["name"] as? String,
            let amount = value["amount"] as? String,
            let isBought  = value["isBought"] as? Bool,
            let order = value["order"] as? Int
            else {
                return nil
        }
        
        self.isBought = isBought
        super.init(key: id, name: name, amount: amount, order: order)
    }
}

class RefrigeratorItem: Ingredient {
    
    override init(key: String, name: String, amount: String, order: Int) {
        super.init(key: key, name: name, amount: amount, order: order)
    }
    
    init?(document:  QueryDocumentSnapshot) {
        
        let value = document.data()
        
        guard
            let id = value["id"] as? String,
            let name = value["name"] as? String,
            let amount = value["amount"] as? String,
            let order = value["order"] as? Int
            else {
                return nil
        }
        
        super.init(key: id, name: name, amount: amount, order: order)
    }
    
    init?(document:  QueryDocumentSnapshot, index: Int) {
        
        let value = document.data()
        
        guard
            let id = value["id"] as? String,
            let name = value["name"] as? String,
            let amount = value["amount"] as? String
            else {
                return nil
        }
        
        super.init(key: id, name: name, amount: amount, order: index)
    }
}


struct DeletingIngredient {
    var index: Int
    var item: Ingredient
    
}
