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
        
        setUpPlayVideoView()
        playVideo()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //        setUpBackBtn()
        //        setUpPlayerBtn()
        //        setUpAddBtn()
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
        self.playView.playBtnView.backgroundColor = UIColor.clear
        
    }
    
    
    
    func setUpAddBtn() {
        
        self.playView.addBtn.setTitle("Add", for: .normal)
        self.playView.addBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        self.playView.addBtn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.playView.addBtn.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.playView.addBtn.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        self.playView.addBtn.clipsToBounds = true
        self.playView.addBtn.layer.cornerRadius = 5
        self.playView.addBtn.backgroundColor = UIColor.white
        self.playView.addBtn.tintColor = UIColor.systemOrange
        
        self.playView.addBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .subscribe(onNext: { [unowned self] in self.viewModel.addVideo() })
            .disposed(by: viewModel.disposeBag)
    }
    
    
    
    func playVideo() {
        
        viewModel.urlSubject
            .subscribe(onNext: { [unowned self] url in
                
                self.player =  AVPlayer(url: url)
                
                self.layerPlayer = createPlayerLayer()
                
                
                view.layer.addSublayer(self.layerPlayer)
                self.setUpPlayVideoView()
                
                self.player.play()
                self.viewModel.isPlayingRelay.onNext(true)
                
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
    
    
    
}

extension UploadingVideoViewController: SemiModalPresenterDelegate {
    
    var semiModalContentHeight: CGFloat {
        return self.view.frame.height
    }
    
}
