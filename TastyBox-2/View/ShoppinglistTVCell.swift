//
//  ShoppinglistTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-27.
//

import UIKit
import RxCocoa
import RxSwift

class ShoppinglistTVCell: UITableViewCell {

    @IBOutlet weak var checkMarkBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var strikeThroghLineView: UIView!
    
    static var identifier: String { String(describing: self) }
    
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    
    func configure(item: ShoppingItem) {
       
        nameLbl.text = item.name
        amountLbl.text = item.amount
        checkMarkBtn.imageView?.tintColor = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
        
        updateCheckMark(isBought: item.isBought)
    }

    func updateCheckMark(isBought: Bool) {

            let image = isBought ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
            
            self.checkMarkBtn.setBackgroundImage(image, for: .normal)
            
            self.strikeThroghLineView.isHidden = !isBought
        
        
    }
  
    
}
