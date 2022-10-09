//
//  CheckEvaluateRecipeCellTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit

final class CheckEvaluateRecipeTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var evaluations: [Evaluation]!
    var likes: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 80, height: 80)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        collectionView.collectionViewLayout = flowLayout
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CheckEvaluateRecipeTVCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evaluations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "checkEvaluateRecipeCVCell", for: indexPath) as! CheckEvaluateRecipeCVCell
        
        switch evaluations[indexPath.row] {
        case .like:
            
            if let img = UIImage(systemName: self.evaluations[indexPath.row].imgName) {
                cell.imgView.image = img
            }
            
            cell.titleLbl.text = "0\nLikes"
            
        default:
            
            cell.imgView.image = UIImage(systemName: evaluations[indexPath.row].imgName)
            cell.titleLbl.text = evaluations[indexPath.row].rawValue
        }
        
        cell.imgView.backgroundColor = #colorLiteral(red: 0.9994645715, green: 0.9797875285, blue: 0.7697802186, alpha: 1)
        cell.imgView.tintColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        
        return cell
        
    }
}
