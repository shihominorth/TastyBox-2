//
//  Genre.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-21.
//

import Foundation
import DifferenceKit
import Firebase
import RxSwift
import RxCocoa
import RxDataSources

struct Genre {
    
    var id: String
    var title: String
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
  
    init?(document:  QueryDocumentSnapshot) {
        
        let data = document.data()
        
        guard let id = data["id"] as? String, let title = data["title"] as? String else { return nil }
        
        self.id = id
        self.title = title
    }
}

extension Genre: Differentiable {
    
    var differenceIdentifier: String {
        return self.id
    }
    
    func isContentEqual(to source: Genre) -> Bool {
        
        return self.id == source.id
    
    }
}


struct SectionOfGenre {
  var header: String
  var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension SectionOfGenre: SectionModelType {

    typealias Item = Genre

    init(original: SectionOfGenre, items: [Item]) {

        self = original
        self.items = items

    }
}
