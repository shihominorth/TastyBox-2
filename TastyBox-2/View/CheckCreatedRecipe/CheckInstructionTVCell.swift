//
//  CheckInstructionTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit
import Kingfisher
import SkeletonView

class CheckInstructionTVCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var instructionLbl: UILabel!
    
    var instruction: Instruction!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        imgView.isSkeletonable = true
//        imgView.isHiddenWhenSkeletonIsActive = false
//        imgView.showAnimatedSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(instruction: Instruction) {
        
        stepLbl.text = "Step \(instruction.index + 1)"
        instructionLbl.text = instruction.text
        
        guard let string = instruction.imageURL else { return }
       
//        if let urlString = instruction.imageURL,  let url = URL(string: urlString), let img = UIImage(data:) {
        if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters),
           let img = UIImage(data: data) {

//            let data = Data(urlString.utf8)
            
//            if let img = UIImage(data: data) {
     
                imgView.image = img
//                imgView.stopSkeletonAnimation()
//                imgView.hideSkeleton()

//            }
//            imgView.kf.setImage(with: url, options: [.transition(.fade(1))]) { [unowned self] result in
                
                
//                switch result {
//                case let .success(value):
//
//                   print("showed: \(value)")
//
//                case let .failure(value):
//
//                    print("failed: \(value)")
//
//                }
        }
    }
}
