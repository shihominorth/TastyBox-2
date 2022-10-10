//
//  RankingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-18.
//

import UIKit
import Kingfisher
import RxSwift

class RankingViewController: UIViewController, BindableType {
      
    typealias ViewModelType = RankingViewModel
    var viewModel: RankingViewModel!

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: RxRecipeRankingCollectionViewDataSource!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        flowLayout.itemSize = CGSize(width: self.view.frame.width * 0.95, height: 174)
        flowLayout.scrollDirection = .vertical

        collectionView.collectionViewLayout = flowLayout
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        viewModel.getRecipsRanking()
            .subscribe(onNext: { recipes in
                
                self.viewModel.recipesSubject.onNext(recipes)
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    

    func bindViewModel() {

        setUpDataSource()

            
        viewModel.recipesSubject
            .flatMapLatest({ [unowned self] recipes in
                self.viewModel.getPublisher(recipes: recipes)
            })
            .withLatestFrom(viewModel.recipesSubject)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
        
        collectionView.rx.itemSelected
            .withLatestFrom(viewModel.recipesSubject) { indexPath, recipes in
            
            return recipes[indexPath.row]
        }
        .catch { err in
            
            print(err)
            
            return .empty()
        }
        .subscribe(onNext: { [unowned self] recipe in
            
            self.viewModel.delegate?.selectedRecipe(recipe: recipe)
            
        })
        .disposed(by: viewModel.disposeBag)
    }
    
  
    func setUpDataSource() {
        
        dataSource = RxRecipeRankingCollectionViewDataSource(configure: { [unowned self] row, recipe, cell in
  
            var isCompletedImgShown = false
            
            if let publisher = self.viewModel.pubishers[recipe.userID], let publisherImgUrl = URL(string: publisher.imageURLString) {
                
                cell.publisherImgView.kf.setImage(with: publisherImgUrl, options: [.transition(.fade(1))]) { result in
                    
                    switch result {
                    case .success:
                        
                        if isCompletedImgShown {
                            
                            cell.titleLbl.hideSkeleton()
                            cell.likedNumLbl.hideSkeleton()
                            cell.publisherLbl.hideSkeleton()
                            
                            cell.titleLbl.text = recipe.title
                            cell.likedNumLbl.text = "\(recipe.likes)"
                            
                            if let name = viewModel.pubishers[recipe.userID]?.name {
                                cell.publisherLbl.text = "\(name)"
                            }
                            
                            if let rank = viewModel.recipeRanking.first(where: { $0.recipeID == recipe.recipeID })?.rank {
                                
                                cell.rankingLbl.text = "\(rank)"
                            }
                          
                        }
                        else {
                            
                            isCompletedImgShown = true
                        
                        }
                        
                    case .failure(let err):
                        print(err.errorDescription ?? "")
                  
                    }
                    
                    
                    
                }
                
            }
            
            if let recipeImgUrl = URL(string: recipe.imgString) {
                
                cell.imgView.kf.setImage(with: recipeImgUrl, options: [.transition(.fade(1))]) { result in
                    
                    switch result {
                    case .success:
                        
                        
                        if isCompletedImgShown {
                            
                            cell.titleLbl.hideSkeleton()
                            cell.likedNumLbl.hideSkeleton()
                            cell.publisherLbl.hideSkeleton()

                            cell.titleLbl.text = recipe.title
                            cell.likedNumLbl.text = "\(recipe.likes)"
                            
                            if let name = viewModel.pubishers[recipe.userID]?.name {
                                cell.publisherLbl.text = "\(name)"
                            }
                            
                            if let rank = viewModel.recipeRanking.first(where: { $0.recipeID == recipe.recipeID })?.rank {
                                
                                cell.rankingLbl.text = "\(rank)"
                            }
                        }
                        else {
                            
                            isCompletedImgShown = true
                        
                        }
                        
                    case .failure(let err):
                        print(err.errorDescription ?? "")
                    }
                    
                }
            
           
            }
            
        })
        
    }


}
