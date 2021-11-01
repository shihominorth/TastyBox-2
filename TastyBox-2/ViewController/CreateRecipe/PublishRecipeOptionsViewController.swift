//
//  PublishRecipeOptionsViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-27.
//

import UIKit
import RxSwift
import RxCocoa

class PublishRecipeOptionsViewController: UIViewController, BindableType {
   
    typealias ViewModelType = PublishRecipeVM
    var viewModel: PublishRecipeVM!


    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.collectionView.frame.width - 20.0, height: 50.0)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView.collectionViewLayout = flowLayout
        
    }
    
    func bindViewModel() {
        
        collectionView.rx.itemSelected
            .share(replay: 1, scope: .forever)
            .skip(1)
            .subscribe(onNext: { [unowned self] indexPath in
                
                if indexPath.row == 0 {
                    
                    self.viewModel.tappedPublishSubject.onNext(())
                    
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.uploadRecipe()
    }
    
    
}

extension PublishRecipeOptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "publishOptionsCVCell", for: indexPath) as! PublishRecipeOptionCVCell
       
        cell.imgView.image =  UIImage(data: viewModel.options[indexPath.row].0)
        cell.imgView.tintColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        
        cell.titleLbl.text = viewModel.options[indexPath.row].1
        cell.titleLbl.textColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        cell.layer.cornerRadius = 10
    
        return cell
        
    }
    
  
}

extension PublishRecipeOptionsViewController: SemiModalPresenterDelegate {
    var semiModalContentHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.3
    }
}
