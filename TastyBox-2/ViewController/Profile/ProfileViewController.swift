//
//  ProfileViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-19.
//

import UIKit
import SkeletonView

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CollectionViewFlowLayoutType(.photos, frame: view.frame).sizeForItem
        flowLayout.sectionInset = CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 1.0
//        flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.width, height: 50.0)
        
        collectionView.collectionViewLayout = flowLayout
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            
            self.collectionView.stopSkeletonAnimation()
            self.view.stopSkeletonAnimation()
            
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        collectionView.isSkeletonable = true
        collectionView.showAnimatedSkeleton(usingColor: .wetAsphalt, transition: .crossDissolve(0.5))
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UICollectionViewDelegate, SkeletonCollectionViewDataSource {
   
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "profileCVCell"
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        switch section {
        case 3:
            return 1
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCVCell", for: indexPath) as? ProfileRecipeCVCell {
            
            cell.isSkeletonable = true
            cell.contentView.isSkeletonable = true
            cell.imgView.isSkeletonable = true
            
            cell.imgView.image = #imageLiteral(resourceName: "2018_Sweet-Sallty-Snack-Mix_5817_600x600")
            
        }
        
        return UICollectionViewCell()
    }
}

class ProfileRecipeCVCell: UICollectionViewCell {
    
    var imgView: UIImageView!
    
    override func awakeFromNib() {
        
        imgView = UIImageView()
        self.addSubview(imgView)
        
    }
}
