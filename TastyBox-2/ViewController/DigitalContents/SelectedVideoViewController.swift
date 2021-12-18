//
//  SelectedVideoViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-15.
//

import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa

class SelectedVideoViewController: UIViewController, BindableType {
    
    typealias ViewModelType = SelectedVideoVM
    var viewModel: SelectedVideoVM!
    
    var addBtn: UIButton!
    //    var addBtn: UIBarButtonItem?
    var videoPlayerView: VideoPlayerView!
    
    //    var playerVideoView = ContainerControlView()
    
    //    let indicator: UIActivityIndicatorView = {
    //
    //        let aiv = UIActivityIndicatorView()
    //        aiv.style = .medium
    //        aiv.translatesAutoresizingMaskIntoConstraints = false
    //
    //        return aiv
    //
    //    }()
    
    //    var player: AVQueuePlayer!
    //    var looper: AVPlayerLooper!
    //
    //    var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.view.addSubview(indicator)
        //
        //        indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //        indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        //        indicator.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.1).isActive = true
        //        indicator.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.1).isActive = true
        //
        //        indicator.startAnimating()
        
        //        setUpPlayVideo()
        //        playVideo(videoAsset: self.viewModel.asset)
        //        videoPlayerView = VideoPlayerView(frame: self.view.frame)
        //        videoPlayerView = VideoPlayerView(frame: self.view.frame, asset: self.viewModel.asset)
        //        self.view.addSubview(videoPlayerView!)
        //
        //        addBtn = UIBarButtonItem()
        //        addBtn?.title = "Add"
        //
        //        addBtn?.rx.tap
        //            .flatMapLatest { [unowned self] _ -> Observable<(Data, URL)> in
        //
        //                return self.viewModel.getVideoUrl()
        //                    .flatMapLatest { url in
        //                        self.viewModel.getThumbnail(url: url).map { data in
        //                            return (data, url)
        //                        }
        //                    }
        //
        //            }
        //            .subscribe(onNext: { [unowned self] data, url in
        //
        //                self.viewModel.addVideo(data: data, url: url)
        //
        //            })
        //            .disposed(by: viewModel.disposeBag)
        //
        //        self.navigationItem.rightBarButtonItem = addBtn
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        videoPlayerView = VideoPlayerView(frame: self.view.frame, asset: self.viewModel.asset)
        addBtn = UIButton()
        
        self.view.addSubview(videoPlayerView!)
        
        self.viewModel.isHiddenSubject
            .bind(to: videoPlayerView.pauseBtn.rx.isHidden)
            .disposed(by: viewModel.disposeBag)
        self.viewModel.isHiddenSubject
            .bind(to: videoPlayerView.videoSlider.rx.isHidden)
            .disposed(by: viewModel.disposeBag)
        self.viewModel.isHiddenSubject
            .bind(to: self.addBtn.rx.isHidden)
            .disposed(by: viewModel.disposeBag)
        
       
        guard let plusImg = UIImage(systemName: "plus.circle.fill") else { return }
        addBtn.setBackgroundImage(plusImg, for: .normal)
        addBtn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        
        
        addBtn!.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(addBtn!)
        
        self.view.bringSubviewToFront(addBtn!)
        
        NSLayoutConstraint.activate([
            
            addBtn!.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.15),
            addBtn!.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.15),
            addBtn!.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            addBtn!.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -80)
            
        ])
        //        addBtn = UIBarButtonItem()
        //        addBtn?.title = "Add"
        
        addBtn.rx.tap
            .flatMapLatest { [unowned self] _ -> Observable<(Data, URL)> in
                
                return self.viewModel.getVideoUrl()
                    .flatMapLatest { url in
                        self.viewModel.getThumbnail(url: url).map { data in
                            return (data, url)
                        }
                    }
                
            }
            .subscribe(onNext: { [unowned self] data, url in
                
                self.viewModel.addVideo(data: data, url: url)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        videoPlayerView.pauseBtn.rx.tap
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .withLatestFrom(self.viewModel.isPlayingSubject)
            .subscribe(onNext: { [unowned self] isPlaying in
                
                self.viewModel.isPlayingSubject.onNext(!isPlaying)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.isPlayingSubject
            .skip(1)
            .subscribe(onNext: { [unowned self] isPlaying in
                
                if isPlaying {
                    
                    guard let image = UIImage(systemName: "pause.circle.fill") else { return }
                    
                    self.videoPlayerView?.pauseBtn.setBackgroundImage(image, for: .normal)
                    
                    self.videoPlayerView?.player?.play()
                    
                    
                }
                else {
                    
                    guard let image = UIImage(systemName: "play.circle.fill") else { return }
                    
                    self.videoPlayerView?.pauseBtn.setBackgroundImage(image, for: .normal)
                    
                    self.videoPlayerView?.player?.pause()
                    
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        guard let videoPlayerView = videoPlayerView else {
            return
        }
        
        videoPlayerView.setUpPlayVideoView(asset: self.viewModel.asset) { [unowned self] (asset, audioMix, args) in
            
            let asset = asset as! AVURLAsset
            
            
            let item = AVPlayerItem(asset: asset)
            
            videoPlayerView.player = AVQueuePlayer(playerItem: item)
            
            videoPlayerView.looper = AVPlayerLooper(player: videoPlayerView.player!, templateItem: item)
            
            let playerLayer = AVPlayerLayer(player: videoPlayerView.player)
            playerLayer.frame = videoPlayerView.frame
            playerLayer.videoGravity = .resizeAspectFill
            videoPlayerView.layer.insertSublayer(playerLayer, at: 0)
            
            videoPlayerView.player?.play()
            
            videoPlayerView.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            
            
            let interval = CMTime(value: 1, timescale: 2)
            
            videoPlayerView.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] progressTime in
                
                if let duration = videoPlayerView.player?.currentItem?.duration {
                    
                    let seconds = CMTimeGetSeconds(progressTime)
                    let durationSeconds = CMTimeGetSeconds(duration)
                    videoPlayerView.videoSlider.value = Float(seconds / durationSeconds)
                    
                }
                
            }
                        
            videoPlayerView.tap.rx.event
                .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
                .withLatestFrom(viewModel.isHiddenSubject)
                .subscribe(onNext: { [unowned self] isViewsHidden in
                    
                    self.viewModel.isHiddenSubject.onNext(!isViewsHidden)
                    
                })
                .disposed(by: viewModel.disposeBag)
            
        }
        
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.videoPlayerView.player?.pause()
        self.videoPlayerView.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
        
    }
    
    func bindViewModel() {
        
        
        //        self.videoPlayerView.isHiddenSubject
        //            .bind(to: viewModel.isHiddenSubject).disposed(by: viewModel.disposeBag)
        
        //        videoPlayerView?.tap?.rx.event
        //            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
        //            .withLatestFrom(viewModel.isHiddenSubject)
        //            .subscribe(onNext: { isPlayerViewHidden in
        //
        //                self.viewModel.isHiddenSubject.onNext(!isPlayerViewHidden)
        //
        //            })
        //            .disposed(by: viewModel.disposeBag)
        
        //        videoPlayerView?.pauseBtn.rx.tap
        //            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
        //            .withLatestFrom(self.viewModel.isPlayingSubject)
        //            .subscribe(onNext: { [unowned self] isPlaying in
        //
        //                self.viewModel.isPlayingSubject.onNext(!isPlaying)
        //
        //            })
        //            .disposed(by: viewModel.disposeBag)
        //
        //        viewModel.isPlayingSubject
        //            .skip(1)
        //            .subscribe(onNext: { [unowned self] isPlaying in
        //
        //                if isPlaying {
        //
        //                    guard let image = UIImage(systemName: "pause.circle.fill") else { return }
        //
        //                    self.videoPlayerView?.pauseBtn.setBackgroundImage(image, for: .normal)
        //
        //                    self.videoPlayerView?.player?.play()
        //
        //
        //                }
        //                else {
        //
        //                    guard let image = UIImage(systemName: "play.circle.fill") else { return }
        //
        //                    self.videoPlayerView?.pauseBtn.setBackgroundImage(image, for: .normal)
        //
        //                    self.videoPlayerView?.player?.pause()
        //
        //                }
        //
        //            })
        //            .disposed(by: viewModel.disposeBag)
        
    }
    
    func setUpPlayVideo() {
        
        //        self.view.addSubview(playerVideoView)
        
        //        let leadingConstraint = playerVideoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        //        let topConstraint = playerVideoView.topAnchor.constraint(equalTo: self.view.topAnchor)
        //        let trailingConstraint = playerVideoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        //        let bottomConstraint = playerVideoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        //
        //        NSLayoutConstraint.activate([
        //            leadingConstraint, topConstraint, trailingConstraint, bottomConstraint
        //        ])
        //
        //        playerVideoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        //        playerVideoView.center = view.center
        //
        //        playerVideoView.backgroundColor = .amethyst
        
    }
    
    func playVideo (videoAsset: PHAsset) {
        
        //        guard (videoAsset.mediaType == .video) else {
        //            print("Not a valid video media type")
        //            return
        //        }
        //
        //        PHCachingImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (asset, audioMix, args) in
        //            let asset = asset as! AVURLAsset
        //
        //            DispatchQueue.main.async { [unowned self] in
        //
        //                let item = AVPlayerItem(asset: asset)
        //
        //                player = AVQueuePlayer(playerItem: item)
        //
        //                looper = AVPlayerLooper(player: player, templateItem: item)
        //
        //                let playerLayer = AVPlayerLayer(player: player)
        //                playerLayer.frame = self.view.frame
        //                playerLayer.videoGravity = .resizeAspect
        //
        //                self.view.layer.addSublayer(playerLayer)
        //
        //                player.play()
        //
        //                self.indicator.stopAnimating()
        //            }
        //        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem.loadedTimeRanges" {
            
            DispatchQueue.main.async { [unowned self] in
                
                self.videoPlayerView?.indicator.stopAnimating()
                self.videoPlayerView?.controlView.backgroundColor = .clear
               
                self.viewModel.isHiddenSubject.onNext(false)
                
            }
            
        }
        else if keyPath == "" {
            
        }
        
    }
    
}

