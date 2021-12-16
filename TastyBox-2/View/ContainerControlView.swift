//
//  PlayerVideoView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-15.
//

import UIKit
import RxSwift

class ContainerControlView: UIView {
    
    var playerBtn: UIButton = {
        
        let btn = UIButton()
        if let img = UIImage(systemName: "play.circle.fill") {
            
            btn.setBackgroundImage(img, for: .normal)
        }
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
        
    }()
    
    let slider: UISlider = {
        
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
       
        return slider
        
    }()
    
    let tap = UITapGestureRecognizer()

    let isHiddenSubject = BehaviorSubject<Bool>(value: true)
    let disposeBag = DisposeBag()
    
    fileprivate func setUpPlayerBtn() {
        
        self.addSubview(playerBtn)
        
        let widthConstraint = playerBtn.widthAnchor.constraint(equalToConstant: 50.0)
        let heightConstraint = playerBtn.heightAnchor.constraint(equalToConstant: 50.0)
        let centerXConstraint = playerBtn.centerXAnchor
            .constraint(equalTo: self.centerXAnchor)
        let centerYConstraint = playerBtn.centerYAnchor
            .constraint(equalTo: self.centerYAnchor)
        
        NSLayoutConstraint.activate([
            
            widthConstraint, heightConstraint, centerXConstraint, centerYConstraint
            
        ])
        
    }
    
    fileprivate func setUpSlider() {
        
        self.addSubview(slider)
        
        let leadingConstraint = slider.leadingAnchor
            .constraint(equalTo: self.leadingAnchor, constant: -30)
        let trailingConstraint = slider.trailingAnchor
            .constraint(equalTo: self.leadingAnchor, constant: -30)
        let bottomConstraint = slider.bottomAnchor
            .constraint(equalTo: self.bottomAnchor, constant: -60)
        let heightConstraint = slider.heightAnchor.constraint(equalToConstant: 30.0)
        
        
        NSLayoutConstraint.activate([
            
            leadingConstraint, trailingConstraint, bottomConstraint, heightConstraint
            
        ])
        
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setUpPlayerBtn()
        setUpSlider()
        self.addGestureRecognizer(tap)
        
        self.isHiddenSubject.bind(to: self.playerBtn.rx.isHidden).disposed(by: disposeBag)
        self.isHiddenSubject.bind(to: self.slider.rx.isHidden).disposed(by: disposeBag)

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}
