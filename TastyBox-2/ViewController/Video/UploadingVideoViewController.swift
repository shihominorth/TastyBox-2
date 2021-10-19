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
    
    var player: AVPlayer!
    var layerPlayer: AVPlayerLayer!
    
    
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
        
        
    }
    
    
    func setUpPlayVideoView() {
        
        self.playView = PlayVideoView()
        playView.frame = view.bounds
        
        setUpBackBtn()
        setUpPlayerBtn()
        setUpAddBtn()
        setUpSlider()
        
        
        let tap = UITapGestureRecognizer()
        
        tap.rx.event
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver { err in
                
                print(err)
                
                return Driver.empty()
            }
            .asObservable()
            .withLatestFrom(viewModel.isPlayingRelay)
            .flatMap { [unowned self] isPlaying in self.viewModel.setIsPlaying(isPlaying: isPlaying) }
            .subscribe(onNext: { [unowned self] isPlaying in
                
                if isPlaying {
                    self.player.play()
                }
                else {
                    self.player.pause()
                }
                
                self.playView.playImgView.image = isPlaying ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill")
                
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
        
    }
    
    
    
    func playVideo() {
        
        viewModel.urlSubject
            .subscribe(onNext: { [unowned self] url in
                
                self.player =  AVPlayer(url: url)
                self.player.actionAtItemEnd = .none
                
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
                
                //                self.viewModel.isPlayingRelay.onNext(true)
                
                //                self.playView.playBtnView.isHidden = true
                
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
            self.viewModel.isPlayingRelay.onNext(true)
            
        }
//        else if keyPath == "actionAtItemEnd"{
//            if let playerItem = object as? AVPlayerItem {
//                playerItem.seek(to: CMTime.zero, completionHandler: nil)
//            }
//        }
    }
    
}

extension UploadingVideoViewController: SemiModalPresenterDelegate {
    
    var semiModalContentHeight: CGFloat {
        return self.view.frame.height
    }
    
}
