//
//  ProfileViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-19.
//

import UIKit
import Kingfisher
import SkeletonView

class ProfileViewController: UIViewController, BindableType {
    
    typealias ViewModelType = ProfileVM
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: ProfileVM!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ProfileRecipeCVCell.self, forCellWithReuseIdentifier: "profileCVCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CollectionViewFlowLayoutType(.photos, frame: view.frame).sizeForItem
        flowLayout.sectionInset = CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 1.0
        //        flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.width, height: 50.0)
        
        collectionView.collectionViewLayout = flowLayout
       

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [unowned self] in
           
            self.collectionView.stopSkeletonAnimation()
            self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))

            self.collectionView.reloadData()
        
        }
        
       

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        collectionView.isSkeletonable = true

        collectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .link), animation: nil, transition: .crossDissolve(0.25))
        
     
    }
    
    
    func bindViewModel() {
        
        self.viewModel.getUserPostedRecipes()
            .subscribe(onNext: { [unowned self] recipes in
                
                
                self.viewModel.recipes = recipes
                
                
            })
            .disposed(by: viewModel.disposeBag)
        
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //        switch section {
        //        case 0:
        return viewModel.recipes.count
        //        default:
        //            return 0
        //        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCVCell", for: indexPath) as? ProfileRecipeCVCell {
            
            
            
            if self.viewModel.recipes.exists {
                
                cell.imgView.image = #imageLiteral(resourceName: "guacamole-foto-heroe-1024x723")
                
            }
            

//            if let imgURL = URL(string: self.viewModel.recipes[indexPath.row].imgString) {
//
//                cell.imgView.kf.setImage(with: imgURL) { result in
//
//
//
//                    switch result {
//
//                    case .failure(let err):
//
//                        print(err)
//
//                    default:
//                        break
//                    }
//
//                }
//
//            }
            
           
            
            return cell
            
        }
        
        return UICollectionViewCell()
    }
}

class ProfileRecipeCVCell: UICollectionViewCell {
    
    var imgView: UIImageView!
    
    override init(frame: CGRect) {
        
        self.imgView = UIImageView()
        
        super.init(frame: frame)
        
        self.addSubview(self.imgView)
        self.imgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            self.imgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imgView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imgView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
        
        self.contentView.isSkeletonable = true
        self.imgView.isSkeletonable = true
        self.isSkeletonable = true

    }
        //
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
