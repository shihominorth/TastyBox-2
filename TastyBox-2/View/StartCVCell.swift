//
//  StartCVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-18.
//

import UIKit

class StartCVCell: UICollectionViewCell {
    @IBOutlet weak var solicitationLbl: UILabel!
    @IBOutlet weak var signUpwithAccountBtn: UIButton!
    @IBOutlet weak var anonymousBtn: UIButton!
    
    func configureCell() {
        signUpwithAccountBtn.layer.cornerRadius = 3
        anonymousBtn.layer.cornerRadius = 3
    }
}
