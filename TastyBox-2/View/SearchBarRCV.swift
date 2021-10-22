//
//  SearchBarRCV.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-21.
//

import UIKit
import RxSwift

class SearchBarRCV: UICollectionReusableView {
        
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        UINib(nibName: "SearchBarRCV", bundle: nil)
//                    .instantiate(withOwner: self, options: nil)
//        loadNib()
        disposeBag = DisposeBag()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
//        loadNib()

    }
    
    func loadNib() {
        
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UICollectionReusableView {
           
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
}
