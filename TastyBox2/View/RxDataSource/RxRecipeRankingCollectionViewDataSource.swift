//
//  RxRecipeRankingDataSource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-19.
//

import UIKit
import DifferenceKit
import Kingfisher
import RxSwift
import RxCocoa

class RxRecipeRankingCollectionViewDataSource: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource  {
   
    typealias Element = [Recipe]
    
    var values: Element = []
    let configure: (Int, Recipe, RecipeRankingCVCell) -> Void
    
    init(configure: @escaping (Int, Recipe, RecipeRankingCVCell) -> Void) {
        
        self.configure = configure
        
    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[Recipe]>) {
        let source = values
       
        let target = observedEvent.element ?? []
    
        let changeset = StagedChangeset(source: source, target: target)
        
        guard changeset.isEmpty else {
            collectionView.reload(using: changeset) { data in
                self.values = data
            }
            
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if values.count < 10 {
            
            return values.count
        }
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeRankingCVCell", for: indexPath) as? RecipeRankingCVCell {
            cell.publisherImgView.layer.cornerRadius = cell.publisherImgView.frame.width / 2
            
            cell.layer.cornerRadius = 5
            cell.layer.borderWidth = 1
            cell.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
            
            configure(indexPath.row, values[indexPath.row], cell)
            
            return cell
        }
    
        return UICollectionViewCell()
    
    }
    
    
    
}
