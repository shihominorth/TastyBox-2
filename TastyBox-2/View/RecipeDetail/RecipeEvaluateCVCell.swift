//
//  RecipeEvaluateCVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit

class RecipeEvaluateCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView! {
        didSet {
            imgView.tintColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        }
    }
    
    @IBOutlet weak var titleLbl: UILabel!
    
}
