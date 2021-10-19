//
//  PlayVideoView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-19.
//

import UIKit

class PlayVideoView: UIView {

    let indicator: UIActivityIndicatorView = {
        
        let result = UIActivityIndicatorView()
        result.style = .large
        result.translatesAutoresizingMaskIntoConstraints = false
        
        result.startAnimating()
        
        return result
    }()
    
    @IBOutlet weak var playBtnView: UIView!
    @IBOutlet weak var playImgView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var slider: UISlider!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        
        self.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
//        setUpPlayBtnView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
//        setUpPlayBtnView()
    }

//    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
//         guard subviews.isEmpty else { return self }
//         return Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first
//     }
    

    func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
           
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
   

}
