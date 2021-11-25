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
    
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
//    fileprivate func showConnectingView() {
        
//        let navigationBar = UINavigationBar()
//        let height = UIScreen.main.bounds.height / 2 - navigationBar.frame.size.height - 50
        
//        indicator.transform = CGAffineTransform(scaleX: 2, y: 2)
//        indicator.center = CGPoint(x: UIScreen.main.bounds.width / 2 , y: height)
//        indicator.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.5)
//        indicator.color = .white
//        indicator.layer.cornerRadius = 10
        
//        self.view.addSubview(indicator)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        showConnectingView()
        let ingredientsCollectionViewFlowLayout = ThereeCellsFlowLayout()
        let recipesCollectionViewFlowLayout = ThereeCellsFlowLayout()
        
        ingredientsCollectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        ingredientsCollectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
       
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

        
            
//            showConnectingView()
            
//            DispatchQueue.global(qos: .default).async {
//
//                // Do heavy work here
//
//                DispatchQueue.main.async { [weak self] in
//                    // UI updates must be on main thread
//                    self?.indicator.startAnimating()
//                }
//            }
        
        if lastNavigationBarIsHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
        }
        
        
        viewModel.getRefrigeratorIngredients()
            .bind(to: viewModel.ingredientSubject)
            .disposed(by: viewModel.disposeBag)
        
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
        

        let selectIngredientsCollectionViewIndexPath =
        ingredientsCollectionView.rx.itemSelected.share(replay: 1, scope: .forever)
            .do(onNext: { [unowned self] indexPath in
                
                self.viewModel.selectedIngredientSubject.onNext(indexPath.row)
                
            })
            
        
        let selectedSingleIngredientIndexPath = selectIngredientsCollectionViewIndexPath.filter { $0.row != 0 }
        
        
        Observable.combineLatest(selectedSingleIngredientIndexPath, viewModel.ingredientSubject) { indexPath, ingredients in
            
            return ingredients[indexPath.row - 1]
            
        }
        .flatMapLatest { [unowned self] ingredient in
            self.viewModel.getRecipes(ingredient: ingredient)
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
        
        selectIngredientsCollectionViewIndexPath
            .filter { $0.row == 0 }
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
        
    }
    
    
    func setUpDataSource() {
        
        ingredientsDataSource = RxDefaultCollectionViewDataSource<String, IngredientOptionCVCell>(identifier: "ingredientsCVCell") { [unowned self] row, ingredient, cell in
 
            self.viewModel.selectedIngredientSubject
                .map { $0 == row }
                .bind(to: cell.isSelectedSubject)
                .disposed(by: cell.disposeBag)

            cell.titleLbl.isSkeletonable = true
            cell.titleLbl.showAnimatedSkeleton()
            
            cell.titleLbl.hideSkeleton()
            
            cell.titleLbl.text = ingredient
        }
        
        recipeDataSource = RxDefaultCollectionViewDataSource<Recipe, RecipeWithIngredientCVCell>(identifier: "recipeWithIngredientCVCell") { row, recipe, cell in
                
            let placeHolder = SkeltonView()
            
            cell.imgView.isSkeletonable = true
            cell.titleLbel.isSkeletonable = true
            
            cell.titleLbel.showAnimatedSkeleton()
            
            if let url = URL(string: recipe.imgString) {
                
                cell.imgView.kf.setImage(with: url, placeholder: placeHolder, options: [.transition(.fade(1))]) { result in
                    
                    switch result {
                    case .success:
                        
                        cell.titleLbel.hideSkeleton()
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





