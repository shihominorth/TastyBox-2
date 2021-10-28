//
//  PublishRecipeOptionsViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-27.
//

import UIKit

class PublishRecipeOptionsViewController: UIViewController, BindableType {
   
    typealias ViewModelType = PublishRecipeVM
    var viewModel: PublishRecipeVM!


    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.dataSource = self
        
    }
    
    func bindViewModel() {
        
        collectionView.rx.itemSelected
            .filter { $0.row == 0 }
            .map { _ in }
            .bind(to: viewModel.tappedPublishSubject )
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
        
        cell.titleLbl.text = viewModel.options[indexPath.row].1
    
        return cell
        
    }
    
  
}
