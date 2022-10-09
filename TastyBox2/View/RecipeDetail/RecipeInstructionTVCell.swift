//
//  RecipeInstructionTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit
import Kingfisher

final class RecipeInstructionTVCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var instructionLbl: UILabel!
   
    var instruction: Instruction!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(instruction: Instruction) {
        
        stepLbl.text = "Step \(instruction.index + 1)"
        instructionLbl.text = instruction.text
        
       
        if let string = instruction.imageURL, let url = URL(string: string) {
            
            imgView.kf.setImage(with: url, options: [.transition(.fade(1))])
            
        }
    }
}
