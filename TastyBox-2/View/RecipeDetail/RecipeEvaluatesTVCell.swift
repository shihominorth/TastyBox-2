//
//  RecipeEvaluatesTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-13.
//

import UIKit
import RxSwift

class RecipeEvaluatesTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var evaluations: [Evaluation]!
    var likes: Int!
    var isLikedSubject: BehaviorSubject<Bool>!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 80, height: 80)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        collectionView.collectionViewLayout = flowLayout
        
        evaluations = []
        likes = 0
        
        isLikedSubject = BehaviorSubject<Bool>(value: false)
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension RecipeEvaluatesTVCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evaluations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeEvaluationCVCell", for: indexPath) as! RecipeEvaluateCVCell
       

        switch evaluations[indexPath.row] {
        case .like:
            
            isLikedSubject
                .subscribe(onNext: { [unowned self] isLiked in
                    
                    if let img = isLiked ? UIImage(systemName: "suit.heart.fill") : UIImage(systemName: self.evaluations[indexPath.row].imgName) {
                       
                        cell.imgView.image = img

                    }
 
                    if isLiked || (!isLiked && likes <= 0) {
                        
                        cell.titleLbl.text = "\(likes ?? 0)\nLikes"
                    }
                    else if !isLiked && likes > 0 {
                        
                        cell.titleLbl.text = "\(likes - 1)\nLikes"
                   
                    }
                   
                  
                    
                })
                .disposed(by: disposeBag)
     
           
            
        default:
            
            cell.imgView.image = UIImage(systemName: evaluations[indexPath.row].imgName)
            cell.titleLbl.text = evaluations[indexPath.row].rawValue
        }
        
      
        
        return cell
        
    }
}
