//
//  IngredientsTableViewCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import UIKit

final class IngredientTableViewCell: UITableViewCell {
//    @IBOutlet private weak var nameLbl: UILabel!
//    @IBOutlet private weak var amountLbl: UILabel!

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!

    
    static var identifier: String { String(describing: self) }
    
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }

    func configure(item: Ingredient) {
        nameLbl.text = item.name
        amountLbl.text = item.amount
    }
}

