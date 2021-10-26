//
//  CheckInstructionTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit

class CheckInstructionTVCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var instructionLbl: UILabel!
    
    var instruction: Instruction!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(instruction: Instruction) {
        
        stepLbl.text = "Step \(instruction.index + 1)"
        imgView.image = UIImage(data: instruction.imageData)
        instructionLbl.text = instruction.text
        
    }
}
