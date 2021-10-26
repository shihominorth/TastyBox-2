//
//  CheckCreatedRecipeViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CheckCreatedRecipeViewController: UIViewController, BindableType {
 

    typealias ViewModelType = CheckRecipeVM
    var viewModel: CheckRecipeVM!

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: RxTableViewSectionedReloadDataSource<RecipeItemSectionModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       
        
    }
    
    
    func bindViewModel() {
        
        setUpDataSource()
        
        viewModel.completeSections()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
       
        tableView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)

    }
    
    
    
    func setUpDataSource() {
        
        dataSource = RxTableViewSectionedReloadDataSource<RecipeItemSectionModel> { dataSource, tableView, indexPath, element in
            
            switch dataSource[indexPath] {
            
            case let .imageData(data, url):
                
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkMainTVCell", for: indexPath) as? CheckMainImageTVCell {
                    
                    cell.imgData = data
                    cell.videoURL = url
                    
                    return cell
                }
                
            case let .title(title):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkTitleTVCell", for: indexPath) as? CheckTitleTVCell {
                    
                    cell.titleLbl.text = title
                    
                    return cell
                }
                
            case let .evaluate(evaluates):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkEvaluateRecipeTVCell", for: indexPath) as? CheckEvaluateRecipeTVCell {

                    cell.evaluates = evaluates
//                    cell.likes = 0
                    
                    return cell
                }
              
            case let .genres(genre):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkGenresTVCell", for: indexPath) as? CheckGenresTVCell {
                    
                    cell.genres = genre
                    
                    return cell
                }
                
            case let .user(user):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkUserTVCell", for: indexPath) as? CheckUserTVCell {
                    
                    cell.user = user
                    
                    return cell
                }
                
            case let .timeAndServing(time, serving):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkTimeNServingTVCell", for: indexPath) as? CheckTimeNServingTVCell {
                    
                    cell.timeLbl.text = "\(time) mins"
                    cell.serveLbl.text = "\(serving) ppl"
                    
                    return cell
                }
                
            case let .ingredients(ingredient):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkIngredientTVCell", for: indexPath) as? CheckIngredientTVCell {
                    
                    cell.ingredient = ingredient
                    cell.configure(ingredient: ingredient)
                    
                    return cell
                }
                
            case let .instructions(instruction):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkInstructionTVCell", for: indexPath) as? CheckInstructionTVCell {

                    cell.instruction = instruction
                    cell.configure(instruction: instruction)
                    
                    return cell
                }
                
            }

            return UITableViewCell()

        }
        
        dataSource.titleForHeaderInSection = { ds, section -> String? in
            return ds[section].title
            
        }
        
    }
}


extension CheckCreatedRecipeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 444
        case 2:
            return 80
        case 4:
            return 60
            
        default:
            return UITableView.automaticDimension
        }
    }
}


