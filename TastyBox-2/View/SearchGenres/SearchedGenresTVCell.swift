//
//  SearchedGenresTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-29.
//

import UIKit
import RxSwift
import RxCocoa

class SearchedGenresTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let flowLayout = GenreCollectionViewFlowLayout()
        
//        flowLayout.headerReferenceSize = CGSize(width: self.contentView.frame.width, height: 100)

        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)

        collectionView.collectionViewLayout = flowLayout
        
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
