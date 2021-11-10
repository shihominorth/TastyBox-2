//
//  SkeltonView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-10.
//

import UIKit
import SkeletonView
import Kingfisher

class SkeltonView: UIView, Placeholder {
    
    func setUpSkeltonView() {
        
        self.isSkeletonable = true
        self.showAnimatedSkeleton()
        self.showSkeleton()
        
    }
}
