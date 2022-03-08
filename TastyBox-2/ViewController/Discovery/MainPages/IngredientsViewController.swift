//
//  IngredientsViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-16.
//

import UIKit
import Firebase
import Kingfisher
import SkeletonView
import RxSwift
import RxCocoa
//import Crashlytics

protocol stopPagingDelegate:  AnyObject {
    func stopPaging(isPaging: Bool)
}

class IngredientsViewController: UIViewController, BindableType {
    
    typealias ViewModelType = IngredientsVM
    var viewModel: IngredientsVM!
    
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!
    @IBOutlet weak var recipesCollecitonView: UICollectionView!
    
    var ingredientsDataSource: RxDefaultCollectionViewDataSource<String, IngredientOptionCVCell>!
    var recipeDataSource: RxDefaultCollectionViewDataSource<Recipe, RecipeWithIngredientCVCell>!
    
    ///  スクロール開始地点
    var scrollBeginPoint: CGFloat = 0.0
    
    /// navigationBarが隠れているかどうか(詳細から戻った一覧に戻った際の再描画に使用)
    var lastNavigationBarIsHidden = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ingredientsCollectionViewFlowLayout = ThereeCellsFlowLayout()
        let recipesCollectionViewFlowLayout = ThereeCellsFlowLayout()
        
        ingredientsCollectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        ingredientsCollectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        ingredientsCollectionViewFlowLayout.scrollDirection = .horizontal
        
        ingredientsCollectionView.collectionViewLayout = ingredientsCollectionViewFlowLayout
        
        let width = (recipesCollecitonView.frame.width - 11) / 2
        recipesCollectionViewFlowLayout.itemSize = CGSize(width: width, height: width * 1.5)
        recipesCollectionViewFlowLayout.minimumLineSpacing = 1
        recipesCollectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        
        recipesCollecitonView.collectionViewLayout = recipesCollectionViewFlowLayout
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        view.backgroundColor = #colorLiteral(red: 0.9998771548, green: 0.9969214797, blue: 0.8987136483, alpha: 1)
        ingredientsCollectionView.backgroundColor = #colorLiteral(red: 1, green: 0.9960784314, blue: 0.8980392157, alpha: 1)
        recipesCollecitonView.backgroundColor = #colorLiteral(red: 0.9998771548, green: 0.9969214797, blue: 0.8987136483, alpha: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if lastNavigationBarIsHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
        }
        
        
        viewModel.getRefrigeratorIngredients()
            .bind(to: viewModel.ingredientSubject)
            .disposed(by: viewModel.disposeBag)
        
        ingredientsCollectionView.isSkeletonable = true
        recipesCollecitonView.isSkeletonable = true
        
        
        ingredientsCollectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete), animation: nil, transition: .crossDissolve(0.25))
        recipesCollecitonView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete), animation: nil, transition: .crossDissolve(0.25))
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [unowned self] in
            
            self.ingredientsCollectionView.stopSkeletonAnimation()
            self.recipesCollecitonView.stopSkeletonAnimation()
            self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            
            self.ingredientsCollectionView.reloadData()
            self.recipesCollecitonView.reloadData()
            
        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        lastNavigationBarIsHidden = false
    }
    
    func bindViewModel() {
        
        setUpDataSource()
        
        viewModel.ingredientSubject
            .map { ingredients in
                
                var ingredientsNames = ingredients.map { $0.name }
                
                ingredientsNames.insert("All", at: 0)
                
                return ingredientsNames
                
            }
            .bind(to: ingredientsCollectionView.rx.items(dataSource: ingredientsDataSource))
            .disposed(by: viewModel.disposeBag)
        
        
        viewModel.ingredientSubject
            .debug("get recipe")
            .flatMapLatest { [unowned self] in
                self.viewModel.getRecipes(allIngredients: $0)
            }
            .catch { err in
                
                return .empty()
            }
            .subscribe(onNext: { recipes in
                
                self.viewModel.recipesSubject.onNext(recipes)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.recipesSubject
            .do(onNext: {
                
                self.viewModel.recipes = $0
                
            })
            .bind(to: recipesCollecitonView.rx.items(dataSource: recipeDataSource))
            .disposed(by: viewModel.disposeBag)
                
                
        ingredientsCollectionView.rx.itemSelected
            .throttle(.milliseconds(1500), scheduler: MainScheduler.instance)
                .do(onNext: { [unowned self] in
                    self.ingredientsCollectionView.scrollToItem(at: $0, at: .centeredHorizontally, animated: true)
                })
                .map { $0.row }
                .bind(to: viewModel.selectedIngredientSubject)
                .disposed(by: viewModel.disposeBag)
        
        
        viewModel.selectedIngredientSubject
            .filter { $0 != 0 }
            .withLatestFrom(self.viewModel.ingredientSubject) { row, ingredients in
                return ingredients[row - 1]
            }
            .flatMapLatest { [unowned self] ingredient in
                self.viewModel.getRecipes(ingredient: ingredient)
            }
            .subscribe(onNext: { recipes in
                        
                self.viewModel.recipesSubject.onNext(recipes)
                        
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.selectedIngredientSubject
            .filter { $0 == 0 }
            .withLatestFrom(viewModel.ingredientSubject)
            .flatMapLatest { [unowned self] in
                self.viewModel.getRecipes(allIngredients: $0)
            }
            .catch { err in

                return .empty()
            }
            .subscribe(onNext: { recipes in

                self.viewModel.recipesSubject.onNext(recipes)

            })
            .disposed(by: viewModel.disposeBag)
        
        
        recipesCollecitonView.rx.itemSelected
            .map { [unowned self] indexPath in
                
                return self.viewModel.recipes[indexPath.row]
                
            }
            .subscribe(onNext: { [unowned self] recipe in
                
                self.viewModel.toRecipeDetail(recipe: recipe)
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    
    func setUpDataSource() {
        
        ingredientsDataSource = RxDefaultCollectionViewDataSource<String, IngredientOptionCVCell>(identifier: "ingredientsCVCell") { [unowned self] row, ingredient, cell in

            self.viewModel.selectedIngredientSubject
                .throttle(.milliseconds(1000), latest: false, scheduler: MainScheduler.instance)
                .map { selectedRow in
                    selectedRow == row
                }
                .subscribe(onNext: { isCellSelected in
                    
                    cell.setViewColors(isCellSelected: isCellSelected)
                    
                })
                .disposed(by: cell.disposeBag)
            
            
            cell.titleLbl.text = ingredient
            
        }
        
        recipeDataSource = RxDefaultCollectionViewDataSource<Recipe, RecipeWithIngredientCVCell>(identifier: "recipeWithIngredientCVCell") { row, recipe, cell in
            
            cell.imgView.isSkeletonable = true
            cell.titleLbel.isSkeletonable = true
            
            if let url = URL(string: recipe.imgString) {
                
                cell.imgView.kf.setImage(with: url) { result in
                    
                    switch result {
                    case .success:
                        
                        cell.titleLbel.text = recipe.title
                        
                    default:
                        break
                    }
                    
                }
            }
            
        }
        
    }
    
    func updateNavigationBarHiding(scrollDiff: CGFloat) {
        
        let boundaryValue: CGFloat = 100.0
        
        /// navigationBar表示
        if scrollDiff > boundaryValue {
            navigationController?.setNavigationBarHidden(false, animated: true)
            lastNavigationBarIsHidden = false
            return
        }
        
        /// navigationBar非表示
        else if scrollDiff < -boundaryValue {
            navigationController?.setNavigationBarHidden(true, animated: true)
            lastNavigationBarIsHidden = true
            return
        }
    }
}


