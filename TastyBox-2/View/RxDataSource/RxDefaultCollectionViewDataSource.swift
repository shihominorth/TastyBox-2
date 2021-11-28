//
//  RxDefaultCollectionViewDataSource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-20.
//

import UIKit
import DifferenceKit
import RxSwift
import RxCocoa

class RxDefaultCollectionViewDataSource<E: Differentiable, Cell: UICollectionViewCell>: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource {
   
    typealias Element = [E]
    
    let identifier: String
    let configure: (Int, E, Cell) -> Void
    var values: Element = []

    
    init(identifier: String, configure: @escaping (Int,  E, Cell) -> Void) {
        
        self.identifier = identifier
        self.configure = configure

    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[E]>) {
        
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
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier, for: indexPath) as? Cell {
                
            configure(indexPath.row, self.values[indexPath.row], cell)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}
