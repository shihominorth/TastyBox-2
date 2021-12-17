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
    
    var addBtn: UIBarButtonItem?
    var videoPlayerView: VideoPlayerView?
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
        self.view.addSubview(videoPlayerView!)
        
        addBtn = UIBarButtonItem()
        addBtn?.title = "Add"
        
        addBtn?.rx.tap
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
        
        self.navigationItem.rightBarButtonItem = addBtn
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.videoPlayerView?.player?.pause()
       

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
        
        videoPlayerView?.pauseBtn.rx.tap
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

}

