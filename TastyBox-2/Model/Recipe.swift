//
//  Recipe.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-16.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageUI

struct Recipe {
    let recipeID: String
    let imageData: Data?
    var title: String
    let updatedDate: Timestamp
    var cookingTime: Int
//    var image: String?
    var like: Int
    var serving: Int
    let userID:String
    var genres: [String] = []
    var isVIPRecipe: Bool?
}



struct Instruction {
    var index: Int
    var imageUrl: String
    var text: String
}

struct Comment {
    var userId: String
    var text: String
    var time: Timestamp
}
