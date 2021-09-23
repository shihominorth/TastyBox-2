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

    init(identifier: String, with animation: UITableView.RowAnimation = .automatic, configure: @escaping (Int, E, Cell) -> Void) {
        self.identifier = identifier
        self.animation = animation
        self.configure = configure
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        let source = values
        let target = observedEvent.element ?? []
        let changeset = StagedChangeset(source: source, target: target)
        tableView.reload(using: changeset, with: animation) { data in
            self.values = data
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
        let row = indexPath.row
        configure(row, values[row], cell)
        return cell
    }

}
