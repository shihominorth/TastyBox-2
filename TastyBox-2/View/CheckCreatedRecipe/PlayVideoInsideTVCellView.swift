//
//  PlayVideoInsideTVCellView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-27.
//

import UIKit
import AVKit
import AVFoundation

class PlayVideoInsideTVCellView: UIView {

    override static var layerClass: AnyClass {
        
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
}
