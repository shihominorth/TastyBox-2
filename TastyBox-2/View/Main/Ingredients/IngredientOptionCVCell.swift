//
//  IngredientOptionCVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-20.
//

import UIKit
import RxSwift

class IngredientOptionCVCell: UICollectionViewCell {
    
    let isSelectedSubject = BehaviorSubject<Bool>(value: false)
    var disposeBag = DisposeBag()
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        
        self.contentView.layer.cornerRadius = 5
        
        disposeBag = DisposeBag()
        
        isSelectedSubject
            .subscribe(onNext: { [unowned self] isCellSelected in
                
                self.setViewColors(isCellSelected: isCellSelected)
                
            })
            .disposed(by: disposeBag)
    }
        
    func setViewColors(isCellSelected: Bool) {
         
        self.contentView.backgroundColor = isCellSelected ? #colorLiteral(red: 0.9882352941, green: 0.8862745098, blue: 0.4549019608, alpha: 1) : #colorLiteral(red: 1, green: 0.9960784314, blue: 0.8980392157, alpha: 1)
//        self.titleLbl.textColor = isCellSelected ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        
    }
    
}
