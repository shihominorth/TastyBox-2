//
//  User.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation
import Firebase

struct User {
    var userID: String
    var name: String
    var imageData: Data
    var cuisineType: String?
    var familySize: Int?
    var isVIP: Bool?
    
    init(id: String, name: String, isVIP: Bool, imgData: Data) {
       
        self.userID = id
        self.name = name
        self.isVIP = isVIP
        self.imageData = imgData
    
    }
    
    init?(document:  DocumentSnapshot, imgData: Data) {
        
        guard let data = document.data() else { return nil }
        
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let isVIP = data["isVIP"] as? Bool
        else {
            return nil
        }
        
        self.userID = id
        self.name = name
        self.isVIP = isVIP
        self.imageData = imgData
    }
//    var followersID: [String]
//    var followingID: [String]
}

struct  AllergicFoodData {
    var allergicFood: String
    var checkedFood: Bool?
}



struct AllFoodList {
    var allFood:[AllergicFoodData]
}




