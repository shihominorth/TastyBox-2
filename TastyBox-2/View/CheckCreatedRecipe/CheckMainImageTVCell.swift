//
//  CheckMainImageTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit

class CheckMainImageTVCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playVideoView: UIView!
    
    var imgData: Data!
    var videoURL: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
