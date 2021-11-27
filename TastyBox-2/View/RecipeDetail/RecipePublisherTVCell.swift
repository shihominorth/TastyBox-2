//
//  RecipePublisherTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit
import Kingfisher
import RxSwift

class RecipePublisherTVCell: UITableViewCell {

    @IBOutlet weak var publisherNameLbl: UILabel!
    @IBOutlet weak var publisherBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    
    var disposeBag = DisposeBag()
    
    var user: User! {

        didSet {

            publisherNameLbl.text = user.name

            if let url = URL(string: user.imageURLString) {
                
                publisherBtn.kf.setImage(with: url, for: .normal, options: [.transition(.fade(1))], completionHandler:  { result in
                    
                    if case .failure = result {
                        
                        print("failed")
                        
                    }
                    else if case .success = result {
                        
                        print("success")
                        
                    }
                })
            }
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        publisherBtn.layer.masksToBounds = true
        publisherBtn.layer.cornerRadius = publisherBtn.frame.width / 2
        publisherBtn.setTitle("", for: .normal)
        
        followBtn.layer.masksToBounds = true
        followBtn.layer.cornerRadius = 15
        followBtn.layer.borderWidth = 2
        
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpFollowingBtn(isFollowing: Bool) {
    
        let title = isFollowing ? "Followed" : "Follow"
        
        followBtn.setTitle(title, for: .normal)
        
        followBtn.backgroundColor = isFollowing ? #colorLiteral(red: 0.9978365302, green: 0.9878997207, blue: 0.7690339684, alpha: 1) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        followBtn.layer.borderColor = isFollowing ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 0.9978365302, green: 0.9878997207, blue: 0.7690339684, alpha: 1)
        
        let color = isFollowing ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        followBtn.tintColor = color
        
    }
    
}
