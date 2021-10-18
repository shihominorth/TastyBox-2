//
//  VideoUploadingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-18.
//

import UIKit
import Lottie

class UploadingVideoViewController: UIViewController, BindableType {
  
    
    typealias ViewModelType = UploadingVideoVM
    var viewModel: UploadingVideoVM!

//    @IBOutlet weak var playerImgView: UIImageView!
  
    @IBOutlet weak var playBtnView: PlayerView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        setUpPlayerBtn()
        setUpAddBtn()
    }
    
    func bindViewModel() {
        
    }
  
    func setUpPlayerBtn() {
        
        playBtnView.layer.borderWidth = 3
        playBtnView.clipsToBounds = true
        playBtnView.layer.cornerRadius = playBtnView.frame.width / 2
        playBtnView.layer.borderColor = UIColor.systemOrange.cgColor
        playBtnView.backgroundColor = UIColor.clear
        
//        self.view.addSubview(self.playerView)
//
//        playerView.translatesAutoresizingMaskIntoConstraints = false
//
//        let num = CGFloat(self.view.frame.width / 3)
//        guard let superView = playerView.superview else { return }
//
////        playerView.frame.size = CGSize(width: num, height: num)
//
//        let widthConstraint = playerView.widthAnchor.constraint(equalToConstant: num)
//        widthConstraint.identifier = "superview width"
//        let heightConstraint = playerView.heightAnchor.constraint(equalToConstant: num)
//        heightConstraint.identifier = "superview height"
//        let centerXConstraint = playerView.centerXAnchor.constraint(equalTo: superView.centerXAnchor)
//        let centerYConstraint = playerView.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
//
//        widthConstraint.isActive = true
//        heightConstraint.isActive = true
//        centerXConstraint.isActive = true
//        centerYConstraint.isActive = true
        
//        playerView.imgView.image = UIImage(systemName: "Play.fill")
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
