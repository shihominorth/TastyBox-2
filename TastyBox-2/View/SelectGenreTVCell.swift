//
//  SelectGenreTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-23.
//

import UIKit

class SelectGenreTVCell: UITableViewCell {

    @IBOutlet weak var selectBtn: UIButton!
//    var isSelectedGenre = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
       
        selectBtn.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        selectBtn.layer.borderWidth = 3
        selectBtn.layer.cornerRadius = 10

        selectBtn.setTitle("Select Genres", for: .normal)
        selectBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        selectBtn.tintColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
    }

    
    func setIsSelectedGenre(isSelected: Bool) {
        
        if isSelected {
            
            selectBtn.setTitle("Check Genres", for: .normal)
            selectBtn.backgroundColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
            selectBtn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        }
        else {
           
            selectBtn.setTitle("Select Genres", for: .normal)
            selectBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            selectBtn.tintColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        
        }
    }
}
