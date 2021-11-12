//
//  RecipePublisherTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit

class RecipePublisherTVCell: UITableViewCell {

    @IBOutlet weak var publisherNameLbl: UILabel!
    @IBOutlet weak var publisherBtn: UIButton!
    
    var user: User! {

        didSet {
        
            publisherNameLbl.text = user.name

            if  let data = Data(base64Encoded: user.imageURLString, options: .ignoreUnknownCharacters), let image = UIImage(data: data) {
                publisherBtn.setBackgroundImage(image, for: .normal)
            }
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        publisherBtn.layer.cornerRadius = publisherBtn.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
