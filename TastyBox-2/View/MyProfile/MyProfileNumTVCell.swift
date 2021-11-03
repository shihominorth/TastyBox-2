//
//  MyProfileNumTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit

class MyProfileNumTVCell: UITableViewCell {

    @IBOutlet weak var myPosetedRecipeNumBtn: UIButton!
    @IBOutlet weak var mySavedRecipesBtn: UIButton!
    @IBOutlet weak var myFollowingNumBtn: UIButton!
    @IBOutlet weak var myFollowedNumBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        myPosetedRecipeNumBtn.titleLabel?.numberOfLines = 0
        myPosetedRecipeNumBtn.titleLabel?.textAlignment = NSTextAlignment.center
        
        mySavedRecipesBtn.titleLabel?.numberOfLines = 0
        mySavedRecipesBtn.titleLabel?.textAlignment = NSTextAlignment.center
        
        myFollowingNumBtn.titleLabel?.numberOfLines = 0
        myFollowingNumBtn.titleLabel?.textAlignment = NSTextAlignment.center
        
        myFollowedNumBtn.titleLabel?.numberOfLines = 0
        myFollowedNumBtn.titleLabel?.textAlignment = NSTextAlignment.center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

