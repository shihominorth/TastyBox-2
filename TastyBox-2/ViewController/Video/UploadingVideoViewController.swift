//
//  VideoUploadingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-18.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import Lottie

class UploadingVideoViewController: UIViewController, BindableType {
    
    
    typealias ViewModelType = UploadingVideoVM
    var viewModel: UploadingVideoVM!
    
    var playerItem: AVPlayerItem!
    var playerLooper: AVPlayerLooper!
    var player: AVQueuePlayer!
    var layerPlayer: AVPlayerLayer!
    
    
    var tap: UITapGestureRecognizer!
    var playView: PlayVideoView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        setUpPlayVideoView()
        playVideo()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layerPlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func bindViewModel() {
        
        
        viewModel.isHiddenPlayingViewRelay
            .bind(to: self.playView.playBtnView.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        viewModel.isHiddenPlayingViewRelay
            .bind(to: self.playView.playImgView.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        viewModel.isHiddenPlayingViewRelay
            .bind(to: self.playView.addBtn.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        viewModel.isHiddenPlayingViewRelay
            .bind(to: self.playView.backBtn.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        
        
        viewModel.isHiddenSliderRelay
            .bind(to: self.playView.slider.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        self.viewModel.isHiddenSliderRelay.accept(true)
        self.viewModel.isHiddenPlayingViewRelay.accept(true)
    }
    
    
    func setUpPlayVideoView() {
        
        self.playView = PlayVideoView()
        playView.frame = view.bounds
        
        setUpBackBtn()
        setUpPlayerBtn()
        setUpAddBtn()
        setUpSlider()
        
        
        tap = UITapGestureRecognizer()
        
        tap.rx.event
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver { err in
                
                print(err)
                
                return Driver.empty()
            }
            .asObservable()
            .withLatestFrom(viewModel.isPlayingRelay)
            .flatMap { [unowned self] in self.viewModel.setIsPlaying(status: $0) }
            .subscribe(onNext: { [unowned self] playStatus in
                
                
                switch playStatus {
                    
                case .hide:
                    
                    self.viewModel.isHiddenSliderRelay.accept(true)
                    self.viewModel.isHiddenPlayingViewRelay.accept(true)
                    
                    self.player.play()
                    
                case .show:
                    
                    self.viewModel.isHiddenPlayingViewRelay.accept(false)
                    self.viewModel.isHiddenSliderRelay.accept(false)
                    
                    self.playView.playImgView.image =  UIImage(systemName: "pause.fill")
                    
                    
                case  .pause:
                    
                    self.player.pause()
                    self.playView.playImgView.image = UIImage(systemName: "play.fill")
                }
                
                
                
                
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        
        self.playView.addGestureRecognizer(tap)
        
        view.addSubview(self.playView)
        
    }
    
    
    
    func setUpBackBtn() {
        
        self.playView.backBtn.setTitle("", for: .normal)
        self.playView.backBtn.layer.cornerRadius = self.playView.frame.width / 2
        self.playView.backBtn.tintColor = .systemOrange
        self.playView.backBtn.layer.borderColor = UIColor.systemOrange.cgColor
        
        
        self.playView.backBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .subscribe(onNext: { [unowned self] in self.viewModel.back() })
            .disposed(by: viewModel.disposeBag)
    }
    
    func setUpPlayerBtn() {
        
        self.playView.playImgView.image = UIImage(systemName: "pause.fill")
        self.playView.playBtnView.layer.borderWidth = 3
        self.playView.playBtnView.clipsToBounds = true
        self.playView.playBtnView.layer.cornerRadius = self.playView.playBtnView.frame.width / 2
        self.playView.playBtnView.layer.borderColor = UIColor.systemOrange.cgColor
        self.playView.playBtnView.backgroundColor = .clear
        
        //        self.playView.playImgView.isHidden = true
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
                
                if let duration = self.player.currentItem?.duration {
                    
                    let totalSeconds = CMTimeGetSeconds(duration)
                    let value = Float64(self.playView.slider.value) * totalSeconds
                    let seekTime = CMTime(value: Int64(value), timescale: 1)
                    
                    
                    player.seek(to: seekTime, completionHandler: { isCompleted in
                        
                    })
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        self.playView.slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        
        
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        
        let subject = PublishSubject<PlayViewStatus>()
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                
                subject
                    .subscribe(onNext: { [unowned self] status in
                        
                        self.viewModel.isHiddenSliderRelay.accept(false)
                    })
                    .disposed(by: viewModel.disposeBag)
                
            case .ended:
                
                subject
                    .withLatestFrom(viewModel.isPlayingRelay)
                    .subscribe(onNext: { [unowned self] status in
                        
                        switch status {
                        case .hide:
                            self.viewModel.isHiddenSliderRelay.accept(true)
                        default:
                            break
                        }
                        
                    })
                    .disposed(by: viewModel.disposeBag)
                
            default:
                break
            }
            
        }
    }
    
    func playVideo() {
        
        viewModel.urlSubject
            .subscribe(onNext: { [unowned self] url in
                
                self.playerItem = AVPlayerItem(url: url)
                self.player =  AVQueuePlayer(playerItem: self.playerItem)
                self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
                
                self.player.addObserver(self, forKeyPath: "actionAtItemEnd", options: [.new], context: nil)
                self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: [.new], context: nil)
                
                self.layerPlayer = createPlayerLayer()
                
                
                view.layer.addSublayer(self.layerPlayer)
                self.setUpPlayVideoView()
                
                self.player.play()
                
                let interval = CMTime(value: 1, timescale: 2)
                
                self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] progressTime in
                    
                    if let duration = self.player.currentItem?.duration {
                        
                        let seconds = CMTimeGetSeconds(progressTime)
                        let durationSeconds = CMTimeGetSeconds(duration)
                        self.playView.slider.value = Float(seconds / durationSeconds)
                        
                    }
                }
                
            }, onError: { err in
                
                print(err)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        
    }
    
    func createPlayerLayer() -> AVPlayerLayer {
        
        let layer = AVPlayerLayer(player: self.player)
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspect
        
        return layer
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            
            playView.indicator.stopAnimating()
            //            self.viewModel.isHiddenPlayingViewRelay.accept(true)
            
            self.viewModel.isPlayingRelay.onNext(.hide)
            
        }
    }
    
}

extension UploadingVideoViewController: SemiModalPresenterDelegate {
    
    var semiModalContentHeight: CGFloat {
        return self.view.frame.height
    }
    
}
