//
//  RxDefaultTableViewDataSource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import UIKit
import DifferenceKit
import RxSwift
import RxCocoa

class RxDefaultTableViewDataSource<E: Differentiable, Cell: UITableViewCell>: NSObject, RxTableViewDataSourceType, UITableViewDataSource {

    typealias Element = [E]
    
    let identifier: String
    let configure: (Int, E, Cell) -> Void
    var values: Element = []

    
    init(identifier: String, configure: @escaping (Int,  E, Cell) -> Void) {
        
        self.identifier = identifier
        self.configure = configure

    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<[E]>) {
        
        let source = values

        let target = observedEvent.element ?? []

        let changeset = StagedChangeset(source: source, target: target)
         
        tableView.reload(using: changeset, with: .none) { data in
                
            self.values = data

        }
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return values.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier, for: indexPath) as? Cell {
                
            configure(indexPath.row, self.values[indexPath.row], cell)
            
            return cell
        }

        return UITableViewCell()

    }
    
}



