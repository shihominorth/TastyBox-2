//
//  MyPageViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit
import RxSwift
import RxCocoa

class MyProfileViewController: UIViewController, BindableType {
    
    typealias ViewModelType = MyProfileVM
    var viewModel: MyProfileVM!

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: RxPostedRecipeCollectionViewDataSource<Recipe, MyPostedRecipeCVCell>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
        setUpCollectionView()
    }
    
    func bindViewModel() {
        
    }
    
    func setUpTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }

    func setUpCollectionView() {
        
        dataSource = RxPostedRecipeCollectionViewDataSource<Recipe, MyPostedRecipeCVCell>(identifier: MyPostedRecipeCVCell.identifier, configure: { row, recipe, cell in
            
            if let data = recipe.imageData, let img = UIImage(data: data) {
                cell.imgView.image = img
            }
            
        })
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
               
                
                
                return cell
            }
            
        case 2:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "myPostedRecipesTVCell") as? MyPostedRecipesTVCell {
               
                
                
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
            return 43.5
            
        case 2:
            return UITableView.automaticDimension
            
        default:
            break
        }
        
        return CGFloat.zero
    }
}
