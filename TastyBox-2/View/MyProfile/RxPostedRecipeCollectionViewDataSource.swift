//
//  RxPostedRecipeCollectionViewDataSource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit
import RxSwift
import RxCocoa
import DifferenceKit

final class RxPostedRecipeCollectionViewDataSource<E: Differentiable, Cell: UICollectionViewCell>: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource {

    
    typealias Element = [E]

    let identifier: String
    let animation: UITableView.RowAnimation
    let configure: (Int, E, Cell) -> Void
    var values: Element = []
    
    init(identifier: String, with animation: UITableView.RowAnimation = .automatic, configure: @escaping (Int, E, Cell) -> Void) {
       
        self.identifier = identifier
        self.animation = animation
        self.configure = configure
        
    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        
        let source = values
       
        let target = observedEvent.element ?? []
        
        let changeset = StagedChangeset(source: source, target: target)
        
        collectionView.reload(using: changeset) { data in
            self.values = data
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell {
            
            configure(indexPath.row, values[indexPath.row], cell)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}
