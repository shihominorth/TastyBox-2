//
//  EditMainImageTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import UIKit

class EditMainImageTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        collectionView.dataSource = self
        
    }

}

extension EditMainImageTVCell: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
          let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "editMainImageCVCell", for: indexPath) as! EditMainImageCVCell
            
            return cell
        }
        else {
            
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "editMainVideoCVCell", for: indexPath) as! EditMainVideoCVCell
              
            return cell
        }
    }
}


