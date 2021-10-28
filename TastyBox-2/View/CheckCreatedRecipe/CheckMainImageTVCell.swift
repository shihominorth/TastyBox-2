//
//  CheckMainImageTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit
import AVFoundation
import RxSwift

class CheckMainImageTVCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playVideoView: PlayVideoInsideTVCellView!
    
    
    var imgData: Data! {
        didSet {
           
            if let data = imgData, let image = UIImage(data: data) {
                self.playVideoView.imgView.image = image
            }
           
        }
    }
    
    var videoURL: URL!
    
    var tap: UITapGestureRecognizer!

    var playerItem: AVPlayerItem!
    var playerLooper: AVPlayerLooper!
    var player: AVQueuePlayer!
    var layerPlayer: AVPlayerLayer!
    
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
        self.playVideoView.playerLayer.frame = self.playVideoView.frame
        self.playVideoView.playerLayer.videoGravity = .resizeAspect
        
        self.slider.value = 0.0
        
        disposeBag = DisposeBag()

//        self.playVideoView.playerLayer.player?.play()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpImageView(data: Data) {
        
        let imgView = UIImageView()
       
        self.playVideoView.addSubview(imgView)
        
        imgView.topAnchor.constraint(equalTo: self.playVideoView.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: self.playVideoView.bottomAnchor).isActive = true
        imgView.leadingAnchor.constraint(equalTo: self.playVideoView.leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: self.playVideoView.trailingAnchor).isActive = true
        imgView.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true

//        if let image = UIImage(data: imgData), let temp = UIImage(systemName: "suit.heart.fill") {
//
//            imgView.image = image
//
//        }
       
        guard let temp = UIImage(systemName: "suit.heart.fill") else { return }
        guard let imgView = self.playVideoView.subviews.first as? UIImageView else { return }
        imgView.image = temp
      
    }
    
    func setSlider() {
      
        let interval = CMTime(value: 1, timescale: 2)
        
        self.playVideoView.playerLayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] progressTime in
            
            if let duration = self.playVideoView.playerLayer.player?.currentItem?.duration {
                
                let seconds = CMTimeGetSeconds(progressTime)
                let durationSeconds = CMTimeGetSeconds(duration)
                self.slider.value = Float(seconds / durationSeconds)
                
            }
        }
        
        self.slider.rx.controlEvent(.valueChanged)
            .catch { err in
                return .empty()
            }
            .subscribe(onNext: { [unowned self] in
                
                if let duration = self.playVideoView.playerLayer.player?.currentItem?.duration {
                    
                    let totalSeconds = CMTimeGetSeconds(duration)
                    let value = Float64(self.slider.value) * totalSeconds
                    let seekTime = CMTime(value: Int64(value), timescale: 1)
                    
                    
                    self.playVideoView.playerLayer.player?.seek(to: seekTime, completionHandler: { isCompleted in
                        
                    })
                }
                
            })
            .disposed(by: disposeBag)
    }

}
