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
    
    override func viewWillAppear(_ animated: Bool) {
        
        viewModel.getMyTimeline()
            .bind(to: viewModel.postsSubject)
            .disposed(by: viewModel.disposeBag)
        
        
    }
    
    
    func bindViewModel() {
        
        setUpTableView()
        
        let recipesStream = viewModel.postsSubject
            .map { posts -> [String] in
                
                let recipeIds = posts.compactMap { post -> String? in
                    
                    if case let .recipe(_, _, recipeId, _) = post {
                        
                        return recipeId
                        
                    }
                    else {
                        return nil
                    }
                    
                }
              
                return recipeIds
            }
            .flatMapLatest { ids in
                self.viewModel.getRecipe(recipeIds: ids)
            }
        
        let publishersStream = viewModel.postsSubject
            .map { posts -> [String] in
                
                let publisherIds = posts.compactMap { post -> String? in
                    
                    if case let .recipe(_, _, _, publisherId) = post {
                        
                        return publisherId
                        
                    }

                    return nil

                }
                
                return publisherIds
            }
            .flatMapLatest { ids in
                self.viewModel.getPublisher(publisherIds: ids)
            }
        
        
        let zippedStreams = Observable.zip(recipesStream, publishersStream)
        
        zippedStreams
            .do(onNext: { recipes, publishers in
                
                
                self.viewModel.recipes = recipes
                self.viewModel.publishers = publishers
                
            })
            .withLatestFrom(viewModel.postsSubject)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
    }
    
    func setUpTableView() {
        
        tableView.register(UINib(nibName: "NormalTimelineTVCell", bundle: nil), forCellReuseIdentifier: "newRecipe")
        tableView.delegate = self
        
        dataSource = RxNoCellTypeTableViewDataSource<Timeline>(configure: { [unowned self] tableView, indexPath, post in
            
            
            switch post {
                
            case let .recipe(_, updateDate, recipeId, publisherId):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "newRecipe") as? NormalTimelineTVCell {
                    
                    if indexPath.row == 0 {
                        cell.upperLineView.isHidden = true
                    }
                    
                    cell.userImgView.layer.cornerRadius = cell.userImgView.frame.width / 2
                    cell.recipeImgView.layer.cornerRadius = 30
                    
                    
                    var isOneImgCompleted = false
                 
                    if let imgRecipeString = viewModel.recipes.first(where: { $0.recipeID == recipeId })?.imgString,
                        let recipeUrl = URL(string: imgRecipeString),
                        let imgPublisherString = self.viewModel.publishers[publisherId]?.imageURLString,
                        let userUrl = URL(string: imgPublisherString),
                       let name = viewModel.publishers[publisherId]?.name {
                        
                        cell.userImgView.hideSkeleton()
                        cell.recipeImgView.hideSkeleton()
                        
                        cell.userImgView.kf.setImage(with: userUrl, options: [.transition(.fade(1))], completionHandler: { _ in
                            
                            
                            if !isOneImgCompleted {
                                isOneImgCompleted = true
                            }
                            else {
                               
                                cell.userNameLbl.hideSkeleton()
                                cell.dateLbl.hideSkeleton()
                                
                                cell.userNameLbl.text = name
                                
                                let format = "yyyy/MM/dd HH:mm:ss Z"
                                let formatter: DateFormatter = DateFormatter()
                                formatter.calendar = Calendar(identifier: .gregorian)
                                formatter.dateFormat = format
                                let stringDate = formatter.string(from: updateDate)
                                
                                
                                cell.dateLbl.text = stringDate
                                
                            }
                          
                            
                        })
                        
                        cell.recipeImgView.kf.setImage(with: recipeUrl, options: [.transition(.fade(1))]) { result in
                            
                            if !isOneImgCompleted {
                                isOneImgCompleted = true
                            }
                            else {
                               
                                cell.userNameLbl.hideSkeleton()
                                cell.dateLbl.hideSkeleton()
                                
                                cell.userNameLbl.text = name
                                
                                let format = "yyyy/MM/dd HH:mm:ss Z"
                                let formatter: DateFormatter = DateFormatter()
                                formatter.calendar = Calendar(identifier: .gregorian)
                                formatter.dateFormat = format
                                let stringDate = formatter.string(from: updateDate)
                                
                                
                                cell.dateLbl.text = stringDate
                                
                            }
                        }
                    }
                    
                    let leftX = cell.recipeImgView.frame.origin.x
                    
                    cell.separatorInset = UIEdgeInsets(top: 0, left: leftX, bottom: 0, right: 0)
                    
                    return cell
                    
                }
                
            }
            
            
            
            return UITableViewCell()
            
        })
        
        let cellTapped: Observable<Timeline> = tableView.rx.itemSelected
            .do(onNext: { [unowned self] indexPath in
                
                self.tableView.deselectRow(at: indexPath, animated: true)
                
            })
            .withLatestFrom(self.viewModel.postsSubject, resultSelector: { indexPath, posts in
                return posts[indexPath.row]
            })
            .share(replay: 1, scope: .forever)
        
        let newRecipePostSelected = cellTapped
            .filter {
            
                if case .recipe = $0 {
                    return true
                }
                else {
                    return false
                }
            }
        
        newRecipePostSelected
            .compactMap { timeline -> Recipe? in
                if case let .recipe(_, _, recipeId, _) = timeline {
                    return self.viewModel.recipes.first(where: { $0.recipeID == recipeId })
                }
                
                return nil
            }
            .subscribe(onNext: { [unowned self] recipe in
                
                self.viewModel.toRecipeDetail(recipe: recipe)
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
}

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    
}
