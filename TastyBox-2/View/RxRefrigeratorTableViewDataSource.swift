//
//  RxRefrigeratorTableViewDataSource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-23.
//

import UIKit
import RxSwift
import RxCocoa
import DifferenceKit

class RxRefrigeratorTableViewDataSource<E: Differentiable, Cell: UITableViewCell>: NSObject, RxTableViewDataSourceType, UITableViewDataSource {
   
    typealias Element = [E]
    
    let identifier: String
    let animation: UITableView.RowAnimation
    let configure: (Int, E, Cell) -> Void
    var values: Element = []
    var emptyValue: E

    init(identifier: String, with animation: UITableView.RowAnimation = .automatic, emptyValue: E, configure: @escaping (Int, E, Cell) -> Void) {
        self.identifier = identifier
        self.animation = animation
        self.configure = configure
        
        self.emptyValue = emptyValue
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        let source = values
        let target = observedEvent.element ?? []
        let changeset = StagedChangeset(source: source, target: target)
        tableView.reload(using: changeset, with: animation) { data in
            self.values = data
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return values.count
            
        case 1:
            return 1
        default:
            break
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
        let row = indexPath.row
        
        switch indexPath.section {
        case 0:
            configure(row, values[row], cell)
            cell.backgroundColor = .white
        case 1:
            configure(row, emptyValue, cell)
            cell.backgroundColor = .clear
        default:
            break
        }
     
        return cell
    }

}
