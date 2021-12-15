//
//  SelectedVideoViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-15.
//

import UIKit
import AVFoundation
import Photos

class SelectedVideoViewController: UIViewController, BindableType {

    typealias ViewModelType = SelelctedVideoVM
    var viewModel: SelelctedVideoVM!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        playVideo(videoAsset: self.viewModel.asset)
    
    }
    
    func bindViewModel() {
        
    }
    
    

    func playVideo (videoAsset: PHAsset) {

        guard (videoAsset.mediaType == .video) else {
            print("Not a valid video media type")
            return
        }

        PHCachingImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (asset, audioMix, args) in
            let asset = asset as! AVURLAsset

            DispatchQueue.main.async {
                
                let player = AVPlayer(url: asset.url)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.view.frame
                playerLayer.videoGravity = .resizeAspect
                
                self.view.layer.addSublayer(playerLayer)
                
                player.play()
                
            }
        }
    }

}
