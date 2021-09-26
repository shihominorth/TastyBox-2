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

    static var identifier: String { String(describing: self) }
    

    func configure(item: ShoppingItem) {
       
        nameLbl.text = item.name
        amountLbl.text = item.amount
        
        let image = item.isBought ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        
        checkMarkBtn.setBackgroundImage(image, for: .normal)
        checkMarkBtn.imageView?.tintColor = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
        
        
    
    }

}