//
//  VideoPlayerLooped.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-01.
//

import Foundation
import AVKit

class VideoPlayerLooped {
    
    public var videoPlayer:AVQueuePlayer?
    public var videoPlayerLayer:AVPlayerLayer?
    var playerLooper: NSObject?
    var queuePlayer: AVQueuePlayer?
    
    func playVideo(url: URL, inView: UIView){
        
        let playerItem = AVPlayerItem(url: url)
        
        videoPlayer = AVQueuePlayer(items: [playerItem])
        playerLooper = AVPlayerLooper(player: videoPlayer!, templateItem: playerItem)
        
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer!.frame = inView.bounds
        videoPlayerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        inView.layer.addSublayer(videoPlayerLayer!)
        
        if let indicator = inView.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            
            indicator.stopAnimating()
            
        }
        
        videoPlayer?.play()
        
    }
    
    func remove() {
        videoPlayerLayer?.removeFromSuperlayer()
        
    }
}
