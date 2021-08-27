//
//  UIImage+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-27.
//

import Foundation
import UIKit

extension UIImage {
    
    func convertToData() -> Data? {
        guard let imgData = self.jpegData(compressionQuality: 0.75) else { return nil }
        
        return imgData
    }
    
    func defineUserImage() -> Data? {
        if let imgData = self.jpegData(compressionQuality: 0.75) {
            return imgData
        } else {
            guard let defaultImg = UIImage(named: "defaultUserImage")?.convertToData()  else { return nil }
            return defaultImg
        }
    }
}
