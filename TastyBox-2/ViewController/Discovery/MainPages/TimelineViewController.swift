//
//  TimelineViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class TimelineViewController: UIViewController, BindableType {
   
    typealias ViewModelType = TimelineVM
    var viewModel: TimelineVM!
    
    var dataSource: RxNoCellTypeTableViewDataSource<Timeline>!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    

    func bindViewModel() {
        
        setUpTableView()
        
    }
    
    func setUpTableView() {
        
        tableView.register(NormalTimelineTVCell.self, forCellReuseIdentifier: "newRecipe")
        
        dataSource = RxNoCellTypeTableViewDataSource<Timeline>(configure: { tableView, indexPath, post in
            
            
            switch post {
           
            case let .recipe(_, updateDate, recipe, publisher):
                    
                if let cell = tableView.dequeueReusableCell(withIdentifier: "newRecipe") as? NormalTimelineTVCell {
                    
                    if indexPath.row == 0 {
                        cell.upperLineView.isHidden = true
                    }
                    
                    if let recipeUrl = URL(string: recipe.imgString), let userUrl = URL(string: publisher.imageURLString) {
                       
                        cell.userImgView.stopSkeletonAnimation()
                        cell.recipeImgView.stopSkeletonAnimation()

                        cell.userImgView.kf.setImage(with: userUrl, options: [.transition(.fade(1))], completionHandler: { _ in
                 
                            
                            cell.userNameLbl.stopSkeletonAnimation()
                            cell.dateLbl.stopSkeletonAnimation()
                            
                            cell.userNameLbl.text = publisher.name
                            
                            let format = "yyyy/MM/dd HH:mm:ss Z"
                            let formatter: DateFormatter = DateFormatter()
                            formatter.calendar = Calendar(identifier: .gregorian)
                            formatter.dateFormat = format
                            let stringDate = formatter.string(from: updateDate)
                            
                            
                            cell.dateLbl.text = stringDate
                           
                            
                        })
                    
//                        cell.recipeImgView.
                    }
                      
                    
                            
                        return cell
                        
                    }
                
            }
        
                
          
            return UITableViewCell()
            
        })
   
    }

}
