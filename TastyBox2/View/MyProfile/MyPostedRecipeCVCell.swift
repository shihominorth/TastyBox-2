//
//  MyPostedRecipeCVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit
import SkeletonView


final class MyPostedRecipeCVCell: UICollectionViewCell {

    static var identifier: String {
        return "myPostedImg"
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var vipImgView: UIImageView!
    
    override func awakeFromNib() {

//        imgView.isSkeletonable = true
        
//        imgView.showAnimatedSkeleton()
    }

}
