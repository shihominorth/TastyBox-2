//
//  GenresTableHeaderView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-21.
//

import UIKit

class GenresTableHeaderView: UIView {

    @IBOutlet weak var `switch`: UISwitch!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()

    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
           
            view.frame = self.bounds
            self.addSubview(view)
        }
    }

}
