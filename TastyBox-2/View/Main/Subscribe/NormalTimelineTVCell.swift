//
//  NormalTimelineTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import UIKit

class NormalTimelineTVCell: UITableViewCell {

    @IBOutlet weak var upperLineView: UIView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var recipeImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImgView.layer.cornerRadius = self.userImgView.frame.width / 2
        self.recipeImgView.layer.cornerRadius = 25
        
        
        self.upperLineView.isSkeletonable = true
        self.userImgView.isSkeletonable = true
        self.userNameLbl.isSkeletonable = true
        self.dateLbl.isSkeletonable = true
        self.recipeImgView.isSkeletonable = true
        
        self.upperLineView.showAnimatedSkeleton()
        self.userImgView.showAnimatedSkeleton()
        self.userNameLbl.showAnimatedSkeleton()
        self.dateLbl.showAnimatedSkeleton()
        self.recipeImgView.showAnimatedSkeleton()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
