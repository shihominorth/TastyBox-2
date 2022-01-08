//
//  MyProfileNumTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit
import RxSwift

class MyProfileNumTVCell: UITableViewCell {

    @IBOutlet weak var myPosetedRecipeNumBtn: UIButton!
    @IBOutlet weak var mySavedRecipesBtn: UIButton!
    @IBOutlet weak var myFollowingNumBtn: UIButton!
    @IBOutlet weak var myFollowersNumBtn: UIButton!
    
    let postedRecipesSubject = BehaviorSubject<Int>(value: 0)
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        disposeBag = DisposeBag()
       
        myPosetedRecipeNumBtn.setTitle("no post\nfounded", for: .normal)
        myPosetedRecipeNumBtn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        myPosetedRecipeNumBtn.titleLabel?.numberOfLines = 0
        myPosetedRecipeNumBtn.titleLabel?.textAlignment = NSTextAlignment.center
        
        mySavedRecipesBtn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        mySavedRecipesBtn.titleLabel?.numberOfLines = 0
        mySavedRecipesBtn.titleLabel?.textAlignment = NSTextAlignment.center
        
        myFollowingNumBtn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        myFollowingNumBtn.titleLabel?.numberOfLines = 0
        myFollowingNumBtn.titleLabel?.textAlignment = NSTextAlignment.center
        
        myFollowersNumBtn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        myFollowersNumBtn.titleLabel?.numberOfLines = 0
        myFollowersNumBtn.titleLabel?.textAlignment = NSTextAlignment.center
        
        postedRecipesSubject
            .subscribe(onNext: { [unowned self] count in
                
                self.myPosetedRecipeNumBtn.setTitle("\(count)\nposted", for: .normal)
                
            })
            .disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

