//
//  RecipeViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-08.
//

import UIKit
import AVFoundation
import DifferenceKit
import Firebase
import RxSwift
import RxCocoa
//import RxDataSources
import RxTimelane
import SwiftMessages
import Lottie

class RecipeViewController: UIViewController, BindableType {
    
    typealias Section = ArraySection<RecipeDetailSectionItem.RawValue, RecipeDetailSectionItem>
    
    typealias ViewModelType = RecipeVM
    var viewModel: RecipeVM!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: RxRecipeTableViewDataSource<Section>!
   
    
    
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let urlString = viewModel.recipe.videoURL, let url = URL(string: urlString) {
            
            self.playerItem = AVPlayerItem(url: url)
            self.player =  AVPlayer(playerItem: self.playerItem)
            
            
            self.player.addObserver(self, forKeyPath: "actionAtItemEnd", options: [.new], context: nil)
            self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: [.new], context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        
    }
    
    func bindViewModel() {
        
        setUpDataSource()
        
        tableView.tableFooterView = UIView()
        
        tableView.register(IngredientsHeaderView.self, forHeaderFooterViewReuseIdentifier: "ingredientsHeader")
        tableView.register(IngredientsHeaderView.self, forHeaderFooterViewReuseIdentifier: "instructionsHeader")
        
        tableView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        
        tableView.rx.didScroll
            .subscribe(onNext: { [unowned self] _ in
                
                let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                
                if let visibleIndexPath = tableView.indexPathForRow(at: visiblePoint) {
                    
                    if visibleIndexPath.row == 0 {
                        
                        if let cell = tableView.visibleCells[0] as? CheckMainImageTVCell {
                            
                            if viewModel.recipe.videoURL != nil  && !viewModel.isEnded {
                                
                                cell.playVideoView.playerLayer.player = self.player
                                
                                UIView.animate(withDuration: 0.2, delay: 2.0, options: [], animations: {
                                    
                                    cell.playVideoView.imgView.alpha = 0.0
                                    
                                }) { isCompleted in
                                    
                                    if isCompleted {
                                        
                                        cell.playVideoView.imgView.isHidden = true
                                        cell.playVideoView.playerLayer.player?.play()
                                        
                                        if viewModel.isDisplayed == false {
                                            
                                            viewModel.isDisplayed = true
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        
        viewModel.getRecipeDetailInfo(recipe: viewModel.recipe)
        //            .flatMapLatest({ [unowned self] sections in
        //                self.viewModel.isLikedRecipe(resultSetions: sections)
        //            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
        
        viewModel.isExpandedSubject
            .skip(1)
            .distinctUntilChanged()  // check if it's needed later.
            .subscribe(onNext: { [unowned self] isExpanded in
                
                let indexPath = IndexPath(row: 0, section: 3)
                
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? CheckGenresTVCell {
                    
                    if (isExpanded && cell.bounds.height == 100) || (!isExpanded && cell.bounds.height != 100) {
                        
                        UIView.animate(withDuration: 0.0, delay: 0.0, options: [], animations: {
                            // do not change animation
                            tableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .none)
                            
                        }) { isCompleted in
                            // do not change animation
                            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        }
                        
                        
                    }
                    
                    
                }
                
                
                
            })
            .disposed(by: viewModel.disposeBag)
        
        tableView.rx.itemSelected
            .filter { $0.section == 4 }
            .subscribe(onNext: { _ in
                
                self.viewModel.toProfileVC()
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        let tappedLike = viewModel.selectedEvaluationSubject
            .filter { $0 == 0 }
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .debug("observe like emitted")
            .withLatestFrom(viewModel.isLikedRecipeSubject)
            .flatMapLatest { [unowned self] in
                self.viewModel.evaluateRecipe(isLiked: $0)
                    .materialize() // 中じゃないとisDisposedされる
            }
            .share(replay: 1, scope: .forever)
        
        let gotIsLiked: Observable<Bool> = tappedLike
            .compactMap { $0.element }
            .do(onNext: { [unowned self] isLiked in
                
                if isLiked {
                    self.viewModel.recipe.likes += 1
                }
                else {
                    self.viewModel.recipe.likes -= 1
                }
                
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
                
                
            })
        
                let errFound = tappedLike
                .compactMap { $0.error }
                .map { $0 as NSError }
        
        
        let noDocFound: Observable<Bool> = errFound
            .filter { $0.code == 5 }
            .flatMapLatest { _ in
                self.viewModel.addNewMyLikedRecipes()
            }
            .do(onNext: { [unowned self] isLiked in
                
                if isLiked {
                    
                    self.viewModel.recipe.likes += 1
                    
                    tableView.reloadSections(IndexSet(integer: 2), with: .none)
                }
                
            })
        
                let otherErrFound: Observable<Bool> = errFound
                .filter { $0.code != 5 }
                .map { err in
                    print(err)
                    
                    return false
                }
        
        let likedMergedObservables = Observable.merge(gotIsLiked, noDocFound, otherErrFound)
        
        likedMergedObservables
            .subscribe(onNext: { isLiked in
                
                print(isLiked)
                
                
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.isLikedRecipe()
            .bind(to: viewModel.isLikedRecipeSubject)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.selectedEvaluationSubject
            .filter { $0 == 1 }
            .subscribe(onNext: { _ in
                
                self.showReportAlertView()
                
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.getLikedNum()
            .subscribe(onNext: { [unowned self] likes in
                
                self.viewModel.recipe.likes = likes
                
            })
            .disposed(by: viewModel.disposeBag)
        
        let isHiddenFollowBtn = viewModel.user.uid == viewModel.recipe.userID
        
        viewModel.isHiddenFollowSubject.onNext(isHiddenFollowBtn)
        
        viewModel.isFollowingPublisher()
            .bind(to: viewModel.isFollowingSubject)
            .disposed(by: viewModel.disposeBag)
        
        
    }
    
    
    
    
    func setUpDataSource() {
        
        dataSource = RxRecipeTableViewDataSource<Section> { [unowned self] tableView, indexPath, section in
            
            switch section.elements[indexPath.row] {
                
            case let .imageData(data, url):
                
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipeMainTVCell", for: indexPath) as? RecipeMainImageTVCell {
                    
                    cell.imgString = data
                    //                    cell.videoString = url
                    
                    //                    if viewModel.isDisplayed == false && viewModel.recipe.videoURL != nil {
                    //
                    //                        cell.playVideoView.playerLayer.player = self.player
                    //                        cell.playVideoView.imgView.alpha = 1.0
                    //
                    //                        cell.setSlider()
                    //
                    //                        UIView.animate(withDuration: 0.2, delay: 2.0, options: [], animations: {
                    //
                    //                            cell.playVideoView.imgView.alpha = 0.0
                    //
                    //                        }) { isCompleted in
                    //
                    //                            if isCompleted {
                    //                                cell.playVideoView.imgView.isHidden = true
                    //                                cell.playVideoView.playerLayer.player?.play()
                    //                                viewModel.isDisplayed = true
                    //                            }
                    //
                    //                        }
                    //
                    //                    }
                    //
                    //                    if viewModel.recipe.videoURL == nil {
                    //
                    cell.slider.isHidden = true
                    //
                    //                    }
                    //                    else {
                    //
                    //                        cell.slider.isHidden = false
                    //
                    //                    }
                    
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .title(title):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipeTitleTVCell", for: indexPath) as? RecipeTitleTVCell {
                    
                    cell.titleLbl.text = title
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .evaluates(evaluations):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipeEvaluatesTVCell", for: indexPath) as? RecipeEvaluatesTVCell {
                    
                    cell.evaluations = evaluations
                    cell.selectionStyle = .none
                    
                    cell.collectionView.rx.itemSelected
                        .debug("like tapped")
                        .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
                        .map { $0.row }
                        .bind(to: viewModel.selectedEvaluationSubject)
                        .disposed(by: cell.disposeBag)
                    
                    viewModel.isLikedRecipeSubject
                        .bind(to: cell.isLikedSubject)
                        .disposed(by: cell.disposeBag)
                    
                    cell.likes = viewModel.recipe.likes
                    
                    
                    return cell
                }
                
            case let .genres(genre):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipeGenresTVCell", for: indexPath) as? RecipeGenresTVCell {
                    
                    cell.genres = genre
                    cell.selectionStyle = .none
                    
                    cell.expandBtn.setTitle("", for: .normal)
                    
                    
                    cell.expandBtn.rx.tap
                        .throttle(.milliseconds(1000), latest: false, scheduler: MainScheduler.instance)
                    // when debug rx.tap, if it does not emit subscribed, completed and disposed, it emits mutiple events without take(1)
                        .take(1)
                        .debug("tapped")
                        .withLatestFrom(viewModel.isExpandedSubject)
                        .subscribe(onNext: { isExpanded in
                            
                            viewModel.isExpandedSubject.accept(!isExpanded)
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                    if let img = viewModel.isExpandedSubject.value ? UIImage(systemName: "chevron.up.circle") : UIImage(systemName: "chevron.down.circle"){
                        cell.expandBtn.setImage(img, for: .normal)
                    }
                    
                    //?
                    if cell.collectionView.collectionViewLayout.collectionViewContentSize.height <= 70 {
                        
                        cell.expandBtn.isHidden = true
                        
                    }
                    
                    return cell
                }
                
            case let .publisher(user):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipePublisherTVCell", for: indexPath) as? RecipePublisherTVCell {
                    
                    cell.user = user
                    cell.selectionStyle = .none
                    
                    viewModel.isHiddenFollowSubject.bind(to: cell.followBtn.rx.isHidden).disposed(by: cell.disposeBag)
                    
                    viewModel.isFollowingSubject
                        .subscribe(onNext: { isFollowing in
                            
                            cell.setUpFollowingBtn(isFollowing: isFollowing)
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                    let tappedFollowBtn = cell.followBtn.rx.tap
                        .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
                        .withLatestFrom(viewModel.isFollowingSubject)
                        .share(replay: 1, scope: .forever)
                    
                    tappedFollowBtn.bind(to: viewModel.tappedFollowBtn).disposed(by: cell.disposeBag)
                    
                    let willUnFollowing = tappedFollowBtn
                        .filter { $0 }
                    
                    let willFollowing = tappedFollowBtn
                        .filter { !$0 }
                    
                    
                    
                    willFollowing
                        .flatMapLatest { _ in
                            self.viewModel.followPublisher(user: viewModel.user, publisher: user)
                        }
                        .catch { err in
                            
                            print(err)
                            
                            return .empty()
                        }
                        .subscribe(onNext: { isCompleted in
                            
                            if isCompleted {
                                print("success")
                                
                                self.viewModel.isFollowingSubject.onNext(true)
                            }
                            else {
                                print("same uid")
                            }
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                    willUnFollowing
                        .flatMapLatest { _ in
                            self.viewModel.unFollowPublisher(user: viewModel.user, publisher: user)
                        }
                        .catch { err in
                            
                            print(err)
                            
                            return .empty()
                        }
                        .subscribe(onNext: { isCompleted in
                            
                            if isCompleted {
                                print("success")
                                self.viewModel.isFollowingSubject.onNext(false)
                            }
                            else {
                                print("same uid")
                            }
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                    
                    return cell
                }
                
            case let .timeAndServing(time, serving):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipeTimeNServingTVCell", for: indexPath) as? RecipeTimeNServingTVCell {
                    
                    cell.timeLbl.text = "\(time) mins"
                    cell.servingLbl.text = "\(serving) serving"
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .ingredients(ingredient):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipeIngredientTVCell", for: indexPath) as? RecipeIngredientTVCell {
                    
                    cell.ingredient = ingredient
                    cell.configure(ingredient: ingredient)
                    cell.selectionStyle = .none
                    
                    
                    return cell
                }
                
            case let .instructions(instruction):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "recipeInstructionTVCell", for: indexPath) as? RecipeInstructionTVCell {
                    
                    cell.instruction = instruction
                    cell.configure(instruction: instruction)
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            }
            
            
            return UITableViewCell()
        }
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            
            //            playView.indicator.stopAnimating()
            
        }
    }
    
    
    @objc func playerDidFinishPlaying() {
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CheckMainImageTVCell {
            
            UIView.animate(withDuration: 0.2, delay: 2.0, options: [], animations: {
                
                cell.playVideoView.imgView.alpha = 1.0
                
            }) { [unowned self] isCompleted in
                
                if isCompleted {
                    
                    viewModel.isEnded = true
                    cell.playVideoView.imgView.isHidden = false
                    cell.slider.isHidden = true
                }
                
            }
            
        }
    }
    
    func showReportAlertView() {
       
        viewModel.toReportVC()
        
    }
}


extension RecipeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 6:
            
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ingredientsHeader") as! IngredientsHeaderView
            
            let label = UILabel()
            label.text = "Ingredients"
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
            label.sizeToFit()
            
            
            view.addSubview(label)
            
            
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
            
            
            if let subview = view.subviews[0] as? UILabel {
                
                label.heightAnchor.constraint(equalToConstant: subview.frame.height).isActive = true
                
            }
            
            return view
            
        case 7:
            
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "instructionsHeader") as! IngredientsHeaderView
            
            let label = UILabel()
            
            label.text = "Instructions"
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
            label.sizeToFit()
            
            view.addSubview(label)
            
            
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
            
            if let subview = view.subviews[0] as? UILabel {
                
                label.heightAnchor.constraint(equalToConstant: subview.frame.height).isActive = true
                
            }
            
            return view
            
        default:
            break
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 461
        case 2:
            return 80
            
        case 3:
            
            return viewModel.isExpandedSubject.value ?  UITableView.automaticDimension : 100
            
        case 4:
            return 60
            
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 6, 7:
            return 87.0
        default:
            break
        }
        
        return CGFloat.zero
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if viewModel.recipe.videoURL != nil {
            
            guard let videoCell = (cell as? CheckMainImageTVCell) else { return }
            
            videoCell.playVideoView.player?.pause()
            videoCell.playVideoView.player = nil
            videoCell.playVideoView.imgView.isHidden = false
            videoCell.playVideoView.imgView.alpha = 1.0
            
        }
    }
    
}




