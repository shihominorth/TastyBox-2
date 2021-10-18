//
//  VideoUploadingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-18.
//

import UIKit
import AVFoundation

class UploadingVideoViewController: UIViewController, BindableType {
    
    
    typealias ViewModelType = UploadingVideoVM
    var viewModel: UploadingVideoVM!
    
//    var url: URL!
    var player: AVPlayer!
    var layerPlayer: AVPlayerLayer!
    
    @IBOutlet weak var playBtnView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideo()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setUpPlayerBtn()
        setUpAddBtn()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layerPlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func bindViewModel() {
        
        
    }
    
    
    func setUpPlayerBtn() {
        
        playBtnView.layer.borderWidth = 3
        playBtnView.clipsToBounds = true
        playBtnView.layer.cornerRadius = playBtnView.frame.width / 2
        playBtnView.layer.borderColor = UIColor.systemOrange.cgColor
        playBtnView.backgroundColor = UIColor.clear
        
    }
    
    
    
    func setUpAddBtn() {
        
        addBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        addBtn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addBtn.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addBtn.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        addBtn.clipsToBounds = true
        addBtn.layer.cornerRadius = 30
        
        addBtn.backgroundColor = UIColor.white
        addBtn.tintColor = UIColor.systemOrange
    }
    
    func playVideo() {
        
        viewModel.urlSubject
            .subscribe(onNext: { [unowned self] url in

                self.player =  AVPlayer(url: viewModel.url)
                
                self.layerPlayer = createPlayerLayer()
               
                view.layer.addSublayer(self.layerPlayer)
                
                player.play()

                self.playBtnView.isHidden = true

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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UploadingVideoViewController: SemiModalPresenterDelegate {
    
    var semiModalContentHeight: CGFloat {
        return self.view.frame.height
    }
    
}
