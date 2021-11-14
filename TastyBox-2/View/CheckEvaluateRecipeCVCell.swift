//
//  CheckEvaluateRecipeCVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-26.
//

import UIKit

class CheckEvaluateRecipeCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView! {
        
        didSet {
            imgView.backgroundColor = #colorLiteral(red: 0.9994645715, green: 0.9797875285, blue: 0.7697802186, alpha: 1)
            imgView.tintColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        }
        
    }
    @IBOutlet weak var titleLbl: UILabel!
    
}
