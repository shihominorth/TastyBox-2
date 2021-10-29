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

    @IBOutlet weak var imgView: UIImageView! {
        didSet {
            imgView.backgroundColor = #colorLiteral(red: 0.9994645715, green: 0.9797875285, blue: 0.7697802186, alpha: 1)
        }
    }
    
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
    
   
//
//    var completion: (CMTime) -> Void {
//
//    }

}
