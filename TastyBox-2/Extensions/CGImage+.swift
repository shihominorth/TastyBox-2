//
//  CGImage+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-20.
//

import Foundation
import CoreGraphics
import ImageIO

extension CGImage {
   
    var data: Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}
