//
//  RxRecipeTableViewDataSource.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-12.
//

import UIKit
import DifferenceKit
import RxSwift
import RxCocoa



class RxRecipeTableViewDataSource<E: DifferentiableSection>: NSObject, RxTableViewDataSourceType, UITableViewDataSource  {

    typealias Element = [E]
    
    let animation: UITableView.RowAnimation
    let configure: (UITableView, IndexPath, E) -> UITableViewCell
    var values: Element = []
    
    init(with animation: UITableView.RowAnimation = .automatic, configure: @escaping (UITableView, IndexPath, E) -> UITableViewCell) {
       
        self.animation = animation
        self.configure = configure
    
    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<[E]>) {
        
        let source = values
        let target = observedEvent.element ?? []
        let changeset = StagedChangeset(source: source, target: target)
        
        tableView.reload(using: changeset, with: .fade) { data in
            self.values = data
        }
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values[section].elements.count
    }
    
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//       
//        switch section {
//        case 5:
//            return "Ingredients"
//            
//        case 6:
//            return "Instructions"
//        default:
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return configure(tableView, indexPath, values[indexPath.section])
        
    }
    
}
