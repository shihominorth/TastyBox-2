//
//  Tutorial.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2022-01-09.
//

import Foundation
import UIKit

class Tutorial {
    
    let title: String
    let imageData: Data
    let explanation: String
    
    init(title: String, imageData: Data, explanation: String) {
        
        self.title = title
        self.explanation = explanation
        self.imageData = imageData
        
    }
    
    convenience init(title: String, image: UIImage, explanation: String) {
        
        if let data = image.convertToData() {

            self.init(title: title, imageData: data, explanation: explanation)

        }
        else {
            
            self.init(title: title, imageData: Data(), explanation: explanation)

            
        }
        
    }
}
