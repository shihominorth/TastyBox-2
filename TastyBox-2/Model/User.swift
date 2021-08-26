//
//  User.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation

struct User {
    var userID: String
    var name: String
//    var image: String
    var cuisineType: String
    var familySize: Int?
    var isVIP: Bool?
    
    
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




