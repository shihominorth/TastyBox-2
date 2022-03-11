//
//  VideoPlayerView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-15.
//

import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa

final class VideoPlayerView: UIView {
    
    let indicator: UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView()
        aiv.style = .medium
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        aiv.startAnimating()
        
        return aiv
        
    }()
    
    var looper: AVPlayerLooper?
    var player: AVQueuePlayer?
    var playerLayer: AVPlayerLayer?
    
    var tap: UITapGestureRecognizer!
    
    let pauseBtn: UIButton = {
        
        let btn = UIButton()
        
        btn.tintColor = .orange
       
        if let image = UIImage(systemName: "pause.circle.fill") {
            
            btn.setBackgroundImage(image, for: .normal)
            
        }
        
        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.isHidden = true
        
        return btn
    }()
    
    let videoSlider: UISlider = {
        
        let slider = UISlider()
        slider.minimumTrackTintColor = .orange
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
        
    }()
    
    
    let controlView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1.0)
//        view.backgroundColor = .amethyst
        
        return view
        
    }()
    
    var isHiddenSubject: BehaviorSubject<Bool>!
    var disposeBag: DisposeBag!
    
    init(frame: CGRect, asset: PHAsset) {
        
//        isHiddenSubject = BehaviorSubject<Bool>(value: true)
        disposeBag = DisposeBag()
        
        tap = UITapGestureRecognizer()
            
        super.init(frame: frame)
        

//        setUpPlayVideoView(asset: asset)

        controlView.frame = frame
        self.addSubview(controlView)

        controlView.addSubview(indicator)

        NSLayoutConstraint.activate([
        
            indicator.centerXAnchor.constraint(equalTo: self.controlView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.controlView.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: self.controlView.frame.width * 0.15),
            indicator.heightAnchor.constraint(equalToConstant: self.controlView.frame.width * 0.15)
            
        ])
        
        
        indicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        indicator.layer.cornerRadius = 20.0

        
        controlView.addSubview(pauseBtn)

        NSLayoutConstraint.activate([
            pauseBtn.centerXAnchor.constraint(equalTo: self.controlView.centerXAnchor),
            pauseBtn.centerYAnchor.constraint(equalTo: self.controlView.centerYAnchor),
            pauseBtn.widthAnchor.constraint(equalToConstant: self.controlView.frame.width * 0.15),
            pauseBtn.heightAnchor.constraint(equalToConstant: self.controlView.frame.width * 0.15)
       
        ])
            
        
        
        controlView.addSubview(videoSlider)
        
        NSLayoutConstraint.activate([
            
            videoSlider.leadingAnchor
                .constraint(equalTo: self.controlView.leadingAnchor, constant: 30),
            videoSlider.trailingAnchor
                .constraint(equalTo: self.controlView.trailingAnchor, constant: -30),
            videoSlider.bottomAnchor
                .constraint(equalTo: self.controlView.bottomAnchor, constant: -60),
            videoSlider.heightAnchor.constraint(equalToConstant: 30.0)
            
        ])
        
        videoSlider.rx.controlEvent(.valueChanged)
            .catch { err in
                return .empty()
            }
            .subscribe(onNext: { [unowned self] in
                
                if let duration = self.player?.currentItem?.duration {
                    
                    let totalSeconds = CMTimeGetSeconds(duration)
                    let value = Float64(self.videoSlider.value) * totalSeconds
                    let seekTime = CMTime(value: Int64(value), timescale: 1)
                    
                    
                    self.player?.seek(to: seekTime, completionHandler: { isCompleted in
                        
                    })
                }
                
            })
            .disposed(by: disposeBag)
        
        controlView.addGestureRecognizer(tap)
        backgroundColor = .black
 
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }
    
    func setUpPlayVideoView(asset: PHAsset, completion: @escaping (AVAsset?, AVAudioMix?, [AnyHashable : Any]?) -> Void) {
        
        guard (asset.mediaType == .video) else {
            print("Not a valid video media type")
            return
        }
        
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: completion) 
        
    }
    
//    func setUpPlayVideoView(asset: PHAsset) {
//
//        guard (asset.mediaType == .video) else {
//            print("Not a valid video media type")
//            return
//        }
//
//        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { [unowned self] (asset, audioMix, args) in
//
//            let asset = asset as! AVURLAsset
//
//
//                let item = AVPlayerItem(asset: asset)
//
//                player = AVQueuePlayer(playerItem: item)
//
//                looper = AVPlayerLooper(player: player!, templateItem: item)
//
//                let playerLayer = AVPlayerLayer(player: player)
//                playerLayer.frame = self.frame
//                playerLayer.videoGravity = .resizeAspectFill
//                self.layer.insertSublayer(playerLayer, at: 0)
//
//                player?.play()
//
////                player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
//
//
//            let interval = CMTime(value: 1, timescale: 2)
//
//            self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] progressTime in
//
//                if let duration = self?.player?.currentItem?.duration {
//
//                    let seconds = CMTimeGetSeconds(progressTime)
//                    let durationSeconds = CMTimeGetSeconds(duration)
//                    self?.videoSlider.value = Float(seconds / durationSeconds)
//
//                }
//
//            }
//
//        }
//
//    }
    
    func setUpContainerView() {
        
        self.addSubview(controlView)
        
        
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        
//        if keyPath == "currentItem.loadedTimeRanges" {
//            
//            DispatchQueue.main.async { [unowned self] in
//                
//                self.indicator.stopAnimating()
//                self.controlView.backgroundColor = .clear
//
//            }
//            
//        }
//        else if keyPath == "" {
//            
//        }
//        
//    }
}
