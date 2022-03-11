//
//  MainMyProfileTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit

final class MainMyProfileTVCell: UITableViewCell {
    
    @IBOutlet weak var myProfileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var editProfileBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        editProfileBtn.layer.cornerRadius = 10
        self.myProfileImgView?.contentMode = .scaleAspectFit
        self.myProfileImgView.layer.masksToBounds = false
        self.myProfileImgView.layer.cornerRadius = self.myProfileImgView.bounds.width / 2
        self.myProfileImgView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
