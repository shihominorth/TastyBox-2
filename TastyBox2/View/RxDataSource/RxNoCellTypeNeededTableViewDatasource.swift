//
//  RxNoCellTypeNeededTableViewDatasource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import UIKit
import DifferenceKit
import RxSwift
import RxCocoa

class RxNoCellTypeTableViewDataSource <E: Differentiable>: NSObject, RxTableViewDataSourceType, UITableViewDataSource {

    typealias Element = [E]
    
    let configure: (UITableView, IndexPath, E) -> UITableViewCell
    var values: Element = []

    
    init(configure: @escaping (UITableView, IndexPath, E) -> UITableViewCell) {
        
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
    
        return configure(tableView, indexPath, values[indexPath.row])
    
    }
    
    
    
    
}
