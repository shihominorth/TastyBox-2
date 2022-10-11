//
//  RankingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-18.
//

import UIKit
import Kingfisher
import RxSwift

final class RankingViewController: UIViewController, BindableType {
    typealias ViewModelType = RankingViewModel
    var viewModel: RankingViewModel!

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: RxRecipeRankingCollectionViewDataSource!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.getRecipesRanking()
            .bind(to: self.viewModel.recipesSubject)
            .disposed(by: viewModel.disposeBag)
    }
    
    func bindViewModel() {
        viewModel.recipesSubject
            .flatMapLatest({ [unowned self] recipes in
                self.viewModel.getPublisher(recipes: recipes)
            })
            .withLatestFrom(viewModel.recipesSubject)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
        collectionView.rx.itemSelected
            .catch { err in
                print(err)
                
                return .empty()
            }
            .withLatestFrom(viewModel.recipesSubject) { indexPath, recipes in
                return recipes[indexPath.row]
            }
            .subscribe(onNext: { [unowned self] recipe in
                self.viewModel.delegate?.selectedRecipe(recipe: recipe)
            })
            .disposed(by: viewModel.disposeBag)
    }
    
  
    private func setUpDataSource() {
        dataSource = RxRecipeRankingCollectionViewDataSource { [weak self] row, recipe, cell in
            
            cell.titleLbl.text = recipe.title
            cell.likedNumLbl.text = "\(recipe.likes)"
            
            if let name = self?.viewModel.pubishers[recipe.userID]?.name {
                cell.publisherLbl.text = "\(name)"
            }
            
            if let rank = self?.viewModel.recipeRanking.first(where: { $0.recipeID == recipe.recipeID })?.rank {
                cell.rankingLbl.text = "\(rank)"
            }
            
            if let publisher = self?.viewModel.pubishers[recipe.userID],
               let publisherImgUrl = URL(string: publisher.imageURLString) {
                cell.publisherImgView.kf.setImage(with: publisherImgUrl, options: [.transition(.fade(1))])
            }
            
            if let recipeImgUrl = URL(string: recipe.imgString) {
                cell.imgView.kf.setImage(with: recipeImgUrl, options: [.transition(.fade(1))])
            }
        }
    }
    
    private func setUpCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        flowLayout.itemSize = CGSize(width: self.view.frame.width * 0.95, height: 174)
        flowLayout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = flowLayout
        
        setUpDataSource()
    }
    

}
