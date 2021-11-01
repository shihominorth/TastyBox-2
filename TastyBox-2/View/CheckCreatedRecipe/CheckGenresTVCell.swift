//
//  CheckIngredientTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit
import RxSwift

class CheckGenresTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var expandBtn: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var genres:[Genre]!
    var isShownFullSize = false
    var shownGenreNum = 3
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        
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
    
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
            //TableViewCellのlayoutIfNeeded()
            self.layoutIfNeeded()
     
            let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
            return CGSize(width: contentSize.width, height: contentSize.height + 39)
    }

}

extension CheckGenresTVCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "checkGenreCVCell", for: indexPath) as? CheckGenresCVCell {
            
            cell.titleLbl.text = "# \(genres[indexPath.row].title)"
            cell.layer.borderWidth = 1
            cell.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
            cell.layer.cornerRadius = 10
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}
