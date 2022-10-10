//
//  VideoUploadingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-18.
//

import UIKit
import AVKit
import RxSwift
import RxCocoa
import Lottie

class UploadingVideoViewController: UIViewController, BindableType {
    
    
    typealias ViewModelType = UploadingVideoVM
    var viewModel: UploadingVideoVM!
    
    public var videoPlayer:AVQueuePlayer?
    public var videoPlayerLayer:AVPlayerLayer?
    var playerLooper: NSObject?
    var queuePlayer: AVQueuePlayer?
    
    
    var tap: UITapGestureRecognizer!
    var playView: PlayVideoView!
    
    
    let loop = VideoPlayerLooped()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        setUpPlayVideoView()
        //        playVideo()
        self.loop.playVideo(url: self.viewModel.url, inView: self.playView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
      
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        videoPlayerLayer?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func bindViewModel() {
        
        viewModel.isHiddenPlayingViewRelay
            .bind(to: self.playView.addBtn.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        viewModel.isHiddenPlayingViewRelay
            .bind(to: self.playView.backBtn.rx.isHidden).disposed(by: viewModel.disposeBag)
        viewModel.isHiddenPlayingViewRelay
            .bind(to: self.playView.slider.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        
        self.viewModel.isHiddenPlayingViewRelay.accept(false)
    }
    
    
    func setUpPlayVideoView() {
        
        self.playView = PlayVideoView()
        playView.frame = view.bounds
        
        setUpBackBtn()
        setUpAddBtn()
        setUpSlider()
        setUpGestureRecognizer()
        
        view.addSubview(self.playView)
        
        let interval = CMTime(value: 1, timescale: 2)
        
        self.videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] progressTime in
            
            if let duration = self.videoPlayer?.currentItem?.duration {
                
                let seconds = CMTimeGetSeconds(progressTime)
                let durationSeconds = CMTimeGetSeconds(duration)
                self.playView.slider.value = Float(seconds / durationSeconds)
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemNewErrorLogEntry), name: .AVPlayerItemNewErrorLogEntry, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemFailedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemPlaybackStalled), name: .AVPlayerItemPlaybackStalled, object: nil)
        
        self.videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: {time in
            if self.videoPlayer?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                self.playView.indicator.startAnimating()
            } else if self.videoPlayer?.timeControlStatus == .playing {
                self.playView.indicator.stopAnimating()
            }
        })
        
        self.videoPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        self.videoPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)
        
        // Watch notifications
        //        NotificationCenter.default.addObserver(self, selector: #selector(didPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
    
    
    func setUpBackBtn() {
        
        self.playView.backBtn.setTitle("", for: .normal)
        self.playView.backBtn.layer.cornerRadius = self.playView.frame.width / 2
        self.playView.backBtn.tintColor = .systemOrange
        self.playView.backBtn.layer.borderColor = UIColor.systemOrange.cgColor
        
        
        self.playView?.backBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .subscribe(onNext: { [unowned self] in self.viewModel.back() })
            .disposed(by: viewModel.disposeBag)
    }
    
    
    func setUpAddBtn() {
        
        self.playView.addBtn.setTitle("Add", for: .normal)
        self.playView.addBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        self.playView.addBtn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.playView.addBtn.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.playView.addBtn.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        self.playView.addBtn.clipsToBounds = true
        self.playView.addBtn.layer.cornerRadius = 5
        self.playView.addBtn.backgroundColor = .systemOrange
        self.playView.addBtn.tintColor = .white
        self.playView.addBtn.layer.borderColor = UIColor.systemOrange.cgColor
        
        self.playView.addBtn.titleEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 100)
        
        self.playView.addBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .subscribe(onNext: { [unowned self] in self.viewModel.addVideo() })
            .disposed(by: viewModel.disposeBag)
    }
    
    func setUpSlider() {
        
        self.playView.slider.rx.controlEvent(.valueChanged)
            .catch { err in
                return .empty()
            }
            .subscribe(onNext: { [unowned self] in
                
                if let duration = self.videoPlayer?.currentItem?.duration {
                    
                    let totalSeconds = CMTimeGetSeconds(duration)
                    let value = Float64(self.playView.slider.value) * totalSeconds
                    let seekTime = CMTime(value: Int64(value), timescale: 1)
                    
                    
                    videoPlayer?.seek(to: seekTime, completionHandler: { isCompleted in
                        
                    })
                }
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    
    
    fileprivate func setUpGestureRecognizer() {
        
        tap = UITapGestureRecognizer()
        
        tap.rx.event
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver { err in
                
                print(err)
                
                return Driver.empty()
            }
            .asObservable()
            .withLatestFrom(viewModel.isHiddenPlayingViewRelay)
            .subscribe(onNext: { isHiddden in
                self.viewModel.isHiddenPlayingViewRelay.accept(!isHiddden)
            })
            .disposed(by: viewModel.disposeBag)
        
        
        self.playView.addGestureRecognizer(tap)
    }
    
    
    func playVideo() {
        
//        viewModel.urlSubject?
//            .subscribe(onNext: { [unowned self] url in
//                
//                
//                
//                
//                
//            }, onError: { err in
//                
//                print(err)
//                
//            })
//            .disposed(by: viewModel.disposeBag)
//        
        
        
    }
    
    //    func createPlayerLayer() -> AVPlayerLayer {
    //
    //        let layer = AVPlayerLayer(player: self.player)
    //        layer.frame = self.view.bounds
    //        layer.videoGravity = .resizeAspect
    //
    //        return layer
    //    }
    
    @objc func itemPlaybackStalled() {
        print("AVPlayerItemNewErrorLogEntry")
    }
    
    @objc func itemNewErrorLogEntry() {
        print("itemNewErrorLogEntry")
    }
    
    
    @objc func itemFailedToPlayToEndTime() {
        print("failed")
    }
    func playVideo(url: URL, inView: UIView){
        
        let playerItem = AVPlayerItem(url: url)
        
        videoPlayer = AVQueuePlayer(items: [playerItem])
        playerLooper = AVPlayerLooper(player: videoPlayer!, templateItem: playerItem)
        
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer!.frame = inView.bounds
        videoPlayerLayer!.videoGravity = .resizeAspectFill
        
        inView.layer.addSublayer(videoPlayerLayer!)
        
  
        
        videoPlayer?.play()
        
    }
    
    func remove() {
        videoPlayerLayer?.removeFromSuperlayer()
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            
            playView.indicator.stopAnimating()
            
        }
        
        if let _ = object as? AVPlayer {
            
            if  keyPath == #keyPath(AVPlayer.currentItem.status) {
                
                let newStatus: AVPlayerItem.Status
                if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
                } else {
                    newStatus = .unknown
                }
                if newStatus == .failed {
                    NSLog("Error: \(String(describing: self.videoPlayer?.currentItem?.error?.localizedDescription)), error: \(String(describing: self.videoPlayer?.currentItem?.error))")
                }
            }
            
        }
        
    }
    
}

extension UploadingVideoViewController: SemiModalPresenterDelegate {
    
    var semiModalContentHeight: CGFloat {
        return self.view.frame.height
    }
    
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
