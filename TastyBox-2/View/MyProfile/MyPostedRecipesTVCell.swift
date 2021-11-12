//
//  MyPostedTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit
import Kingfisher
import SkeletonView
import RxSwift
import RxCocoa

class MyPostedRecipesTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
           
            let flowLayout = ThereeCellsFlowLayout()
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            collectionView.collectionViewLayout = flowLayout
            
            collectionView.delegate = self

            
        }
    }
    
    let recipesSubject = BehaviorRelay<[Recipe]>(value: [])
    var disposeBag = DisposeBag()
    var dataSource: RxPostedRecipeCollectionViewDataSource<Recipe, MyPostedRecipeCVCell>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        
        setUpCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension MyPostedRecipesTVCell {
    
    func setUpCollectionView() {
        
        disposeBag = DisposeBag()
        
        dataSource = RxPostedRecipeCollectionViewDataSource<Recipe, MyPostedRecipeCVCell>(identifier: MyPostedRecipeCVCell.identifier, configure: { row, recipe, cell in
            
            cell.vipImgView.isHidden = true
            let placeHolder = SkeltonView()
            

            if let url = URL(string: recipe.imgString) {
            
                cell.imgView.kf.setImage(with: url, placeholder: placeHolder, options: [.transition(.fade(1))])

                cell.vipImgView.isHidden = recipe.isVIP ? false : true

            }
            
        })

        recipesSubject
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
}

extension MyPostedRecipesTVCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return  CGSize(width: (collectionView.frame.width - 2.0) / 3.0, height: (collectionView.frame.width - 2.0) / 3.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
}
