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
    let configure: (Int, Int, E, Cell) -> Void
    var values: Element = []
    var emptyValue: E

    init(identifier: String, with animation: UITableView.RowAnimation = .automatic, emptyValue: E, configure: @escaping (Int, Int, E, Cell) -> Void) {
        self.identifier = identifier
        self.animation = animation
        self.configure = configure
        
        self.emptyValue = emptyValue
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        let source = values
        let target = observedEvent.element ?? []
        let changeset = StagedChangeset(source: source, target: target)
        
        if changeset.isEmpty {
            //MARK: ここでedit, addされた時のtableviewの更新をする。
            tableView.reloadData()
            self.values = target
        }
        else {
            tableView.reload(using: changeset, with: animation) { data in
                self.values = data
            }
            
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
        
        switch indexPath.section {
        case 0:
            configure(indexPath.section, indexPath.row, values[indexPath.row], cell)
            cell.backgroundColor = .white
//            cell.separatorInset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        case 1:
//            configure(indexPath.section, indexPath.row, emptyValue, cell)
            cell.backgroundColor = .clear
//            cell.separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0);
            cell.isSelected = false
        default:
            break
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
        if indexPath.section == 1 {
           return false
        }
        
        return true
    }
    
}
