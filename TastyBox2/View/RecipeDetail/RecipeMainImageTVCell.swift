//
//  RecipeMainTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit
import AVFoundation
import Kingfisher
import RxSwift

final class RecipeMainImageTVCell: UITableViewCell {

    @IBOutlet weak var playVideoView: PlayVideoInsideTVCellView!
    @IBOutlet weak var slider: UISlider!
    
    
    var imgString: String! {
       
        didSet {

            if let url = URL(string: imgString) {

                self.playVideoView.imgView.kf.setImage(with: url, options: [.transition(.fade(1))])

            }
        
        }
    }

    var videoURL: URL!

    var videoString: String? {
        didSet {
            if let videoString = videoString, let url = URL(string: videoString) {
                videoURL = url
            }
            
        }
    }

    
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.playVideoView.playerLayer.frame = self.playVideoView.frame
        self.playVideoView.playerLayer.videoGravity = .resizeAspect
        
        self.slider.value = 0.0
        
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
