//
//  MyPageViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import SkeletonView

class MyProfileViewController: UIViewController, BindableType {
    
    typealias ViewModelType = MyProfileVM
    var viewModel: MyProfileVM!

    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()

    }
    
    func bindViewModel() {
        
        self.viewModel.getMyPostedRecipes()
    }
    
    func setUpTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
}

extension MyProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        switch indexPath.row {
        case 0:
           
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MainMyProfile") as? MainMyProfileTVCell {
               
                if let name = viewModel.user.displayName {

                    cell.nameLbl.text = name

                }
                
                
                return cell
            }
            
        case 1:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "myProfileNum") as? MyProfileNumTVCell {
               
                viewModel.postedRecipesSubject
                    .flatMap { recipes in
                        
                        return Observable.just(recipes.count)
                    }
                    .bind(to: cell.postedRecipesSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            
        case 2:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "myPostedRecipesTVCell") as? MyPostedRecipesTVCell {
               
                viewModel.postedRecipesSubject
                    .bind(to: cell.recipesSubject)
                    .disposed(by: cell.disposeBag)
                
                Observable.combineLatest(cell.collectionView.rx.itemSelected, viewModel.postedRecipesSubject) { indexPath, recipes in

                    return recipes[indexPath.row]

                }
                .subscribe(onNext: { [unowned self] recipe in

                    self.viewModel.toRecipeDetail(recipe: recipe)

                })
                .disposed(by: cell.disposeBag)
                
      
                
                return cell
            }
            
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.row {
       
        case 0:
            return 135
        
        case 1:
            return 50.5
            
        case 2:
            return self.tableView.frame.height - 135 - 50.5
            
        default:
            break
        }
        
        return CGFloat.zero
    }
}
