//
//  RankingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-18.
//

import UIKit
import Kingfisher

class RankingViewController: UIViewController, BindableType {
      
    typealias ViewModelType = RankingVM
    var viewModel: RankingVM!

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: RxRecipeRankingDataSource!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        flowLayout.itemSize = CGSize(width: 405, height: 174)
        flowLayout.scrollDirection = .vertical

        collectionView.collectionViewLayout = flowLayout
        
        
    }
    

    func bindViewModel() {

        setUpDataSource()
        
        viewModel.getRecipsRanking()
            .bind(to: viewModel.recipesSubject)
            .disposed(by: viewModel.disposeBag)

            
        viewModel.recipesSubject
            .flatMapLatest({ [unowned self] recipes in
                self.viewModel.getPublisher(recipes: recipes)
            })
            .withLatestFrom(viewModel.recipesSubject)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
    }
    
  
    func setUpDataSource() {
        
        dataSource = RxRecipeRankingDataSource(configure: { [unowned self] row, recipe, cell in
            
            let placeHolder = SkeltonView()
            
            var isCompletedImgShown = false
            
            if let publisher = self.viewModel.pubishers[recipe.userID], let publisherImgUrl = URL(string: publisher.imageURLString) {
                
                cell.publisherImgView.kf.setImage(with: publisherImgUrl, placeholder: placeHolder, options: [.transition(.fade(1))]) { result in
                    
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
                
                cell.imgView.kf.setImage(with: recipeImgUrl, placeholder: placeHolder, options: [.transition(.fade(1))]) { result in
                    
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
