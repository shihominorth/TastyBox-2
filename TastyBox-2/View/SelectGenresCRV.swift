//
//  SelectGenresCRV.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-29.
//

import UIKit
import RxSwift
import RxCocoa

class SelectGenresCRV: UICollectionReusableView {
        
    @IBOutlet weak var txtView: GenreTxtView!
    
    var isHeightCalculated: Bool = false

 
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        //Exhibit A - We need to cache our calculation to prevent a crash.
            if !isHeightCalculated {
                setNeedsLayout()
                layoutIfNeeded()
                let size = self.systemLayoutSizeFitting(layoutAttributes.size)
                var newFrame = layoutAttributes.frame
                newFrame.size.width = CGFloat(ceilf(Float(size.width)))
                layoutAttributes.frame = newFrame
                isHeightCalculated = true
            }
            return layoutAttributes
    }
}
