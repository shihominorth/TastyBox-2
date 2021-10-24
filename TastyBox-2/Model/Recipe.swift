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
import RxDataSources

struct Recipe {
    
    let recipeID: String
    let imageData: Data?
    let video: URL?
    var title: String
    let updatedDate: Timestamp
    var cookingTime: Int
    //    var image: String?
    var likes: Int
    var serving: Int
    let userID:String
    var genres: [String] = []
    var isVIPRecipe: Bool?
}



struct Instruction {
    var index: Int
    var imageData: Data
    var text: String
}

struct Comment {
    var userId: String
    var text: String
    var time: Timestamp
}

struct Evaluate {
    
    var title: String
    var imgData: Data
    
}


enum RecipeDetailSectionItem {
    case imageData(Data, URL), title(String), evaluate([Evaluate], Int), timeAndServing(Int, Int), user(User), genres([Genre]), ingredients([Ingredient]), instructions([Instruction]) //likes(Int), serving(Int), videoURL(URL),
}

enum RecipeItemSectionModel {
    
//    case mainImageData(content: [RecipeDetailSectionItem])
//    case videoURL(content: [RecipeDetailSectionItem])
//    case title(content: [RecipeDetailSectionItem])
//    case evaluate(content: [RecipeDetailSectionItem])
//    case timeAndServing(content: [RecipeDetailSectionItem])
//    case likes(content: [RecipeDetailSectionItem])
//    case serving(content: [RecipeDetailSectionItem])
//    case user(content: [RecipeDetailSectionItem])
    case genresSection(content: [RecipeDetailSectionItem])
//    case isVIP(content: [RecipeDetailSectionItem])
    case ingredientSection(content: [RecipeDetailSectionItem])
    case instructionSection(content: [RecipeDetailSectionItem])
    
}


extension RecipeItemSectionModel: SectionModelType {
    
    typealias Item = RecipeDetailSectionItem
    
    var items: [RecipeDetailSectionItem] {
        
        switch self {
            
//        case let .mainImageData(data):
//            return data
            
//        case let .videoURL(url):
//            return url
            
//        case let .title(title):
//            return title
//
//        case let .evaluate(data):
//            return data
//
//        case let .timeAndServing(data):
        
//            return data
            
//        case let .serving(serving):
//            return serving
            
//        case let .likes(likes):
//            return likes
//
        case let .genresSection(genres):
            return genres
            
//        case let .user(user):
//            return user
//
//        case let .isVIP(isVIP):
//            return isVIP
            
        case let .ingredientSection(ingredients):
            return ingredients
            
        case let .instructionSection(instructions):
            return instructions
        }
    }
    
    var title: String {
        
        switch self {
        case .ingredientSection:
            return "Ingredients"
        case .instructionSection:
            return "Instructions"
        default:
            return ""
        }
    }
    
    init(original: RecipeItemSectionModel, items: [RecipeDetailSectionItem]) {
        
        switch original {
            
//        case .mainImageData:
//            self = .mainImageData(content: items)
//
//        case .videoURL:
//            self = .videoURL(content: items)
            
//        case .title:
//            self = .title(content: items)
//
//        case .timeAndServing(content: items):
//
//            self = .timeAndServing(content: items)
//
//        case .likes:
//            self = .likes(content: items)
//
//        case .serving:
//            
//            self = .likes(content: items)
//        case .evaluate(content: items):
//            self = .evaluate(content: items)
//
//        case .user:
//
//            self = .likes(content: items)
            
//        case .evaluate:
//
//            self = .evaluate(content: items)
//
        case .genresSection:
            
            self = .genresSection(content: items)
            
//        case .isVIP:
//            
//            self = .isVIP(content: items)
            
        case .ingredientSection:
            
            self = .ingredientSection(content: items)
            
        case .instructionSection:
            
            self = .instructionSection(content: items)
        }
    }
    
}
