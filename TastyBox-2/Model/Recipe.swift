//
//  Recipe.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-16.
//

import UIKit
import DifferenceKit
import Firebase
import FirebaseFirestore
import MessageUI
import RxSwift
import RxDataSources

class Recipe {
    
    let recipeID: String
    let imgURL: String
//    var imageData: Data
    let videoURL: String?
    var title: String
    let updateDate: Timestamp
    var cookingTime: Int
    //    var image: String?
    var likes: Int
    var serving: Int
    let userID:String
    var genresIDs: [String] = []
    var isVIP: Bool
    
    init?(queryDoc:  QueryDocumentSnapshot) {
        
        let data = queryDoc.data()
        
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let updateDate = data["updateDate"] as? Timestamp,
              let time = data["time"] as? Int,
              let serving = data["serving"] as? Int,
              let isVIP = data["isVIP"] as? Bool,
              let publisherID = data["publisherID"] as? String,
              let genresData = data["genres"] as? [String: Bool],
              let imgURL = data["imgURL"] as? String
        else { return nil }
        
        
        self.recipeID = id
        self.title = title
        self.updateDate = updateDate
        self.cookingTime = time
        self.likes = data["likes"] as? Int ?? 0
        self.userID = publisherID
        self.serving = serving
        self.isVIP = isVIP
        self.genresIDs = [String](genresData.keys)
        self.imgURL = imgURL
        
        if let videoURL = data["videoURL"] as? String {
        
            self.videoURL = videoURL
        
        }
        else {
        
            self.videoURL = nil
        
        }
        
    }
    
    static func generateNewRecipes(queryDocs: [QueryDocumentSnapshot]) -> Observable<[Recipe]> {
        
        return .create { observer in
            
            let recipes = queryDocs.compactMap({ doc in
                return Recipe(queryDoc: doc)
            })
            
            observer.onNext(recipes)
            
            return Disposables.create()
        }
    }
}

extension Recipe: Differentiable {
    
    var differenceIdentifier: String {
        return self.recipeID
    }
    
    func isContentEqual(to source: Recipe) -> Bool {
        
        return self.recipeID == source.recipeID
        
    }
}

struct Instruction {
    
    
    var id: String
    var index: Int
    var imageURL: String?
    var text: String
    
    init(id: String, index: Int, imageURL: String?, text: String) {
        
        self.id = id
        self.index = index
        self.imageURL = imageURL
        self.text = text
        
    }
    
    init?(queryDoc: QueryDocumentSnapshot) {
        
        let data = queryDoc.data()
        
        guard let id = data["id"] as? String,
        let index = data["index"] as? Int,
        let text = data["text"] as? String
        else { return nil }
        
        let imageURL = data["imageURL"] as? String
        
        self.id = id
        self.index = index
        self.imageURL = imageURL
        self.text = text
        
    }
    
    static func generateNewInstructions(queryDocs: [QueryDocumentSnapshot]) -> Observable<[Instruction]> {
        
        return .create { observer in
            
            let instructions = queryDocs.compactMap { doc in

                return Instruction(queryDoc: doc)

            }
            
            observer.onNext(instructions)
            
            return Disposables.create()

        }
        
        
    }
}

struct Comment {
    var userId: String
    var text: String
    var time: Timestamp
}

struct Evaluate {
    
    var title: String
    var imgName: String
    
}


enum RecipeDetailSectionItem {
        
    case imageData(Data, URL?)
    case title(String)
    case evaluates([Evaluate])
    case timeAndServing(Int, Int)
    case publisher(User)
    case genres([Genre])
    case ingredients(Ingredient)
    case instructions(Instruction) //likes(Int), serving(Int), videoURL(URL),
}

extension RecipeDetailSectionItem: RawRepresentable {
 
    public typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        
        case "image":
            self = .imageData(Data(), nil)
        
        case "title":
            self = .title("")
            
        case "evaluates":
            self = .evaluates([])
            
        case "timeAndServing":
            self = .timeAndServing(0, 0)

        case "publisher":
            self = .publisher(User(id: "", name: "", isVIP: false, imgData: Data()))
            
        case "genres":
            self = .genres([])
            
        case "ingredients":
            self = .ingredients(Ingredient(key: "", name: "", amount: "", order: 0))
            
        case "instructions":
            self = .instructions(Instruction(id: "", index: 0, imageURL: nil, text: ""))
            
        default:
            return nil
        }
    }

    var rawValue: String {
        switch self {
        case .imageData:
            return "image"
        case .title:
            return "title"
        case .evaluates:
            return "evaluates"
        case .timeAndServing:
            return "timeAndServing"
        case .publisher:
            return "publisher"
        case .genres:
            return "genres"
        case .ingredients:
            return "ingredients"
        case .instructions:
            return "instructions"
        }
    }
    
}

extension RecipeDetailSectionItem: Differentiable {

    var differenceIdentifier: String {
        return self.rawValue
    }
    
    func isContentEqual(to source: RecipeDetailSectionItem) -> Bool {
        return self.rawValue == source.rawValue
    }
}

enum RecipeItemSectionModel {
    
    case mainImageData(imgData: Data, videoURL: URL?)
    case title(title: String)
    case evaluate(evaluates: RecipeDetailSectionItem)
    case timeAndServing(time: Int, serving: Int)
    case user(user: User)
    case genres(genre: RecipeDetailSectionItem)
    case ingredients(ingredient: [RecipeDetailSectionItem])
    case instructions(instruction: [RecipeDetailSectionItem])
    
}


extension RecipeItemSectionModel: SectionModelType {
    
    typealias Item = RecipeDetailSectionItem
    
    var items: [RecipeDetailSectionItem] {
        
        switch self {
            
        case .mainImageData(let imgData, let videoURL):
            return [RecipeDetailSectionItem.imageData(imgData, videoURL)]
            
        case .title(let title):
            
            return [RecipeDetailSectionItem.title(title)]
            
        case .evaluate(let evaluates):
            
            return [evaluates]
            
            
        case .timeAndServing(let time, let serving):
            
            return [RecipeDetailSectionItem.timeAndServing(time, serving)]
            
        case .user(let user):
            
            return [RecipeDetailSectionItem.publisher(user)]
            
        case .genres(let genres):
            
            return [genres]
            
        case .ingredients(let ingredients):
            
            return ingredients.map { $0 }
            
        case .instructions(let instructions):
            
            return instructions.map { $0 }
        }
    }
    
    var title: String {
        
        switch self {
        case .ingredients:
            return "Ingredients"
        case .instructions:
            return "Instructions"
        default:
            return ""
        }
    }
    
    init(original: RecipeItemSectionModel, items: [RecipeDetailSectionItem]) {
        
        switch original {
            
        case let .mainImageData(imgData, videoURL):
            
            self = .mainImageData(imgData: imgData, videoURL: videoURL)
            
        case let .title(title):
            
            self = .title(title: title)
            
        case let .evaluate(evaluates):
            
            self = .evaluate(evaluates: evaluates)
            
        case let .timeAndServing(time, serving):
            
            self = .timeAndServing(time: time, serving: serving)
            
        case let .user(user):
            
            self = .user(user: user)
            
        case let .genres(genres):
            
            self = .genres(genre: genres)
            
        case .ingredients(_):
            
            self = .ingredients(ingredient: items)
            
        case .instructions(_):
            
            self = .instructions(instruction: items)
        }
        //        switch original {
        
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
        //        case .genresSection:
        //
        //            self = .genresSection(content: items)
        
        //        case .isVIP:
        //
        //            self = .isVIP(content: items)
        
        //        case .ingredientSection:
        //
        //            self = .ingredientSection(content: items)
        
        //        case .instructionSection:
        //
        //            self = .instructionSection(content: items)
        //        }
    }
    
}
