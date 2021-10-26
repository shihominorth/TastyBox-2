//
//  CheckUserTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit

class CheckUserTVCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImgViewBtn: UIImageView!
    var user: User! {
        didSet {
            userNameLbl.text = user.name
           
            if let image = UIImage(data: user.imageData) {
                userImgViewBtn.image = image
            }
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImgViewBtn.layer.cornerRadius = userImgViewBtn.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
