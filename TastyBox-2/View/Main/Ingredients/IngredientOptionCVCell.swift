//
//  IngredientOptionCVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-20.
//

import UIKit
import RxSwift

class IngredientOptionCVCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    @IBOutlet weak var titleLbl: UILabel!
    
    var row: Int?
    let isCellSelectedSubject = BehaviorSubject<Bool>(value: false)


    override func awakeFromNib() {
        
        self.contentView.layer.cornerRadius = 5
        
        disposeBag = DisposeBag()
 
    }
    
    func setViewColors(selectedIndex: Int) {
        
        guard let row = row else {
            return
        }
        
        self.contentView.backgroundColor = selectedIndex == row ? #colorLiteral(red: 0.9882352941, green: 0.8862745098, blue: 0.4549019608, alpha: 1) : #colorLiteral(red: 1, green: 0.9960784314, blue: 0.8980392157, alpha: 1)

        
    }
        
}
