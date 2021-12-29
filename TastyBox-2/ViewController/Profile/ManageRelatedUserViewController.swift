//
//  ManageRelatedUserViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-26.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa


class ManageRelatedUserViewController: UIViewController, BindableType {
 
    typealias ViewModelType = ManageMyRelatedUserVM
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: ManageMyRelatedUserVM!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(OptionCVCell.self, forCellWithReuseIdentifier: "manageRelatedUserOptionCVCell")
        collectionView.register(ManageUserCRV.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "manageRelatedUserHeader")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.05)
        flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.1)
        
        collectionView.collectionViewLayout = flowLayout
        
        
    }

    func bindViewModel() {
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                
                switch indexPath.row {
                case 0:
                    
                    self.viewModel.delete()
                    
                case 1:
                    
                    self.viewModel.cancel()
                    
                default:
                    break
                }
                
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

extension ManageRelatedUserViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "manageRelatedUserOptionCVCell", for: indexPath) as? OptionCVCell {
            
            if indexPath.row == 0 {
                
                cell.titleLbl.text = "Delete"
                cell.titleLbl.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                
            }
            else if indexPath.row == 1 {
                
                cell.titleLbl.text = "Cancel"
                
            }
            
            return cell
        }
        
       
        return UICollectionViewCell()
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 && kind == UICollectionView.elementKindSectionHeader {
            
            if let crv = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "manageRelatedUserHeader", for: indexPath) as? ManageUserCRV {
                
                if let url = URL(string: viewModel.manageUser.user.imageURLString) {
                    crv.userImgView.kf.setImage(with: url)
                }
                
                crv.layoutIfNeeded()
                crv.userImgView.layer.cornerRadius = crv.userImgView.frame.width / 2
                
                
                crv.userNameLbl.text = viewModel.manageUser.user.name
                
                return crv
                
            }
            
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.15)
        }
        
        return CGSize.zero
        
    }
    
    
}

extension ManageRelatedUserViewController: SemiModalPresenterDelegate {
    var semiModalContentHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.3
    }
}


class OptionCVCell: UICollectionViewCell {
    
    let titleLbl: UILabel
    
    override init(frame: CGRect) {
    
        titleLbl = {
           
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            
            return lbl
            
        }()
        
        super.init(frame: frame)
        
        self.addSubview(titleLbl)
        
        NSLayoutConstraint.activate([
            
            titleLbl.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: self.frame.width * 0.03),
            titleLbl.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            titleLbl.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor)
            
        ])
    
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class ManageUserCRV: UICollectionReusableView {
    
    let userImgView: UIImageView
    let userNameLbl: UILabel
    
    override init(frame: CGRect) {
        
        userImgView = {
            
            let imgView = UIImageView()
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.clipsToBounds = true
            
            return imgView
            
        }()
        
        userNameLbl = {
            
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.textAlignment = .center
            
            return lbl
        
        }()
        
       
        super.init(frame: frame)
        
        self.addSubview(userImgView)
        self.addSubview(userNameLbl)
        
        NSLayoutConstraint.activate([
        
            userImgView.centerXAnchor.constraint(equalTo: self.layoutMarginsGuide.centerXAnchor),
            userImgView.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            userImgView.widthAnchor.constraint(equalToConstant: self.frame.width * 0.2),
            userImgView.heightAnchor.constraint(equalToConstant: self.frame.width * 0.2)
            
        ])
        

        NSLayoutConstraint.activate([
                
            userNameLbl.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            userNameLbl.topAnchor.constraint(equalTo: self.userImgView.bottomAnchor, constant: 10),
            userNameLbl.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
