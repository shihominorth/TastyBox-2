//
//  ShoppingHeaderView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-27.
//

import UIKit
import RxCocoa

class ShoppinglistHeaderView: UITableViewHeaderFooterView {

    let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var img = UIImage(systemName: "checkmark.circle")
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.8392156863, blue: 0.6784313725, alpha: 1)
        setUpBtn()
    }


    func setUpBtn() {
        
        btn.layer.cornerRadius = btn.frame.size.width / 2
        btn.clipsToBounds = true
        btn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btn.tintColor = UIColor.systemOrange
        btn.setBackgroundImage(img, for: .normal)
        //これがないと表示されない
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(btn)
  
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 30),
            btn.heightAnchor.constraint(equalToConstant: 30),
            btn.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            btn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
       
    }

    func isShowBoughtItems(isShown: Bool) {
        img = isShown ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle")
        btn.setBackgroundImage(img, for: .normal)
    }

}
