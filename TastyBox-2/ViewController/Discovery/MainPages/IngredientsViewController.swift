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
    
    var ingredientsDataSource: RxDefaultCollectionViewDataSource<Ingredient, IngredientOptionCVCell>!
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
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
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
            .subscribe(onNext: { [unowned self] ingredients in
                
                self.viewModel.ingredientSubject.onNext(ingredients)
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        lastNavigationBarIsHidden = false
    }
    
    func bindViewModel() {
        
        setUpDataSource()
        
        viewModel.ingredientSubject
            .bind(to: ingredientsCollectionView.rx.items(dataSource: ingredientsDataSource))
            .disposed(by: viewModel.disposeBag)
        
        viewModel.recipesSubject
            .bind(to: recipesCollecitonView.rx.items(dataSource: recipeDataSource))
            .disposed(by: viewModel.disposeBag)
   
        
        viewModel.ingredientSubject
            .flatMapLatest { [unowned self] in
                self.viewModel.getRecipeWithMutipleIngredients(ingredients: $0)
            }
            .bind(to: viewModel.recipesSubject)
            .disposed(by: viewModel.disposeBag)
        
    }
    
    
    func setUpDataSource() {
        
        ingredientsDataSource = RxDefaultCollectionViewDataSource<Ingredient, IngredientOptionCVCell>(identifier: "ingredientsCVCell") { row, ingredient, cell in
            
            cell.titleLbl.isSkeletonable = true
            cell.titleLbl.showAnimatedSkeleton()
            
            cell.titleLbl.hideSkeleton()
            
            cell.titleLbl.text = ingredient.name
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




