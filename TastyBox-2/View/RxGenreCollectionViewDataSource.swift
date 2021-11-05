//
//  RxGenreCollectionViewDataSource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-23.
//

import UIKit
import DifferenceKit
import RxSwift
import RxCocoa

class RxGenreCollectionViewDataSource<E: Differentiable, Cell: UICollectionViewCell>: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource {
    
    typealias Element = [E]

    let identifier: String
    let configure: (Int, E, Cell) -> Void
    let reloadTableView: () -> Void
    var values: Element = []

    init(identifier: String, configure: @escaping (Int,  E, Cell) -> Void, reloadTableView: @escaping () -> Void) {
        
        self.identifier = identifier
        self.configure = configure
        self.reloadTableView = reloadTableView
    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[E]>) {
        
        let source = values
       
        let target = observedEvent.element ?? []
        
        let changeset = StagedChangeset(source: source, target: target)
        
        collectionView.reload(using: changeset) { data in
            self.values = data
            
            reloadTableView()
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
