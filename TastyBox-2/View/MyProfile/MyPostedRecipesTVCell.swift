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
            
            if let url = URL(string: recipe.imgURL) {
               
                cell.imgView.kf.setImage(with: url, options: [.transition(.fade(1))]) { result in
                    
//                    cell.stopSkeletonAnimation()
                    
                    switch result {
                    case let .success(value):
                        
                        print("showed: \(url), value: \(value)")
                        
                        
                    case let .failure(value):
                      
                        print("failed: \(url), value: \(value)")

                    }
                    
                }
            }
         
            cell.vipImgView.isHidden = recipe.isVIP ? false : true
            
        })

        recipesSubject
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
}
