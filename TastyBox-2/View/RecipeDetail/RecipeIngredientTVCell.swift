//
//  RecipeIngredientTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit

final class RecipeIngredientTVCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!

    var ingredient: Ingredient!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(ingredient: Ingredient) {
        
        nameLbl.text = ingredient.name
        amountLbl.text = ingredient.amount
        
    }
}
