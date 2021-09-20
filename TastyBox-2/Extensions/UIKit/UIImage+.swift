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
    
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
