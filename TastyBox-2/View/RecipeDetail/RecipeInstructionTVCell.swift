//
//  RecipeInstructionTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit

class RecipeInstructionTVCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var instructionLbl: UILabel!
   
    var instruction: Instruction!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//         Initialization code
        imgView.isSkeletonable = true
//        imgView.isHiddenWhenSkeletonIsActive = false
        imgView.showAnimatedSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(instruction: Instruction) {
        
        stepLbl.text = "Step \(instruction.index + 1)"
        instructionLbl.text = instruction.text
        
        guard let string = instruction.imageURL else { return }
       
        if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters),
           let img = UIImage(data: data) {

            imgView.image = img
            imgView.stopSkeletonAnimation()
            imgView.hideSkeleton()
        }
    }
}
