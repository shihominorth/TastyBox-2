//
//  RecipePublisherTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit
import Kingfisher

class RecipePublisherTVCell: UITableViewCell {

    @IBOutlet weak var publisherNameLbl: UILabel!
    @IBOutlet weak var publisherBtn: UIButton!
    
    
    var user: User! {

        didSet {

            publisherNameLbl.text = user.name

            if let url = URL(string: user.imageURLString) {
                
                publisherBtn.kf.setImage(with: url, for: .normal, options: [.transition(.fade(1))], completionHandler:  { result in
                    
                    if case .failure = result {
                        
                        print("failed")
                        
                    }
                    else if case .success = result {
                        
                        print("success")
                        
                    }
                })
            }
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        publisherBtn.layer.masksToBounds = true
        publisherBtn.layer.cornerRadius = publisherBtn.frame.width / 2
        publisherBtn.setTitle("", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
