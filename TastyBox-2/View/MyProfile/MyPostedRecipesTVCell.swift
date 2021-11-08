//
//  MyPostedTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit
import RxSwift
import RxCocoa

class MyPostedRecipesTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let recipesSubject = BehaviorSubject<[Recipe]>(value: [])
    var disposeBag = DisposeBag()
    var dataSource: RxPostedRecipeCollectionViewDataSource<Recipe, MyPostedRecipeCVCell>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        disposeBag = DisposeBag()
        
        dataSource = RxPostedRecipeCollectionViewDataSource<Recipe, MyPostedRecipeCVCell>(identifier: MyPostedRecipeCVCell.identifier, configure: { row, recipe, cell in
            
            if let img = UIImage(data: recipe.imageData) {
                cell.imgView.image = img
            }
            
            cell.vipImgView.isHidden = recipe.isVIP ? false : true
            
        })

//        recipesSubject
//            .bind(to: collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
