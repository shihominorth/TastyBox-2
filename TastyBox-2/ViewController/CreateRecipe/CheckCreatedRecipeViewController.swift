//
//  CheckCreatedRecipeViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import RxDataSources
import RxTimelane
import Lottie

class CheckCreatedRecipeViewController: UIViewController, BindableType {
    
    
    typealias ViewModelType = CheckRecipeVM
    var viewModel: CheckRecipeVM!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: RxTableViewSectionedReloadDataSource<RecipeItemSectionModel>!
    
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    
    let publishBtn = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let url = viewModel.videoUrl {
            
            self.playerItem = AVPlayerItem(url: url)
            self.player =  AVPlayer(playerItem: self.playerItem)
            
            // loopのため
    
            self.player.addObserver(self, forKeyPath: "actionAtItemEnd", options: [.new], context: nil)
            
            // slliderのため
//            self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: [.new], context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
        }
        
        
        publishBtn.title = "Publish"
        
        
        self.navigationItem.rightBarButtonItem = publishBtn

    }
 
    
    func bindViewModel() {
        
        setUpDataSource()
        
        viewModel.completeSections()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
        
        tableView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        
        tableView.rx.didScroll
            .subscribe(onNext: { [unowned self] _ in
                
                let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                
                if let visibleIndexPath = tableView.indexPathForRow(at: visiblePoint) {
                    
                    if visibleIndexPath.row == 0 {
                        
                        if let cell = tableView.visibleCells[0] as? CheckMainImageTVCell {
                            
                            if viewModel.videoUrl != nil  && !viewModel.isEnded {
                                
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
        
        
        publishBtn.rx.tap
            .debug()
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .subscribe(onNext: { _ in
                
                self.viewModel.uploadRecipe()
                
            })
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
        
    }
    
    
    
    
    func setUpDataSource() {
        
        dataSource = RxTableViewSectionedReloadDataSource<RecipeItemSectionModel> { [unowned self] dataSource, tableView, indexPath, element in
            
            switch dataSource[indexPath] {
                
            case let .imageData(imgString, url):
                
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkMainTVCell", for: indexPath) as? CheckMainImageTVCell {
                    
                    cell.imgData = imgString
                    cell.videoString = url
                    
                    if viewModel.isDisplayed == false && viewModel.videoUrl != nil {
                        
                        cell.playVideoView.playerLayer.player = self.player
                        cell.playVideoView.imgView.alpha = 1.0
                        
                        cell.setSlider()
                        
                        UIView.animate(withDuration: 0.0, delay: 2.0, options: [], animations: {
                            
                            cell.playVideoView.imgView.alpha = 0.0
                            
                        }) { isCompleted in
                            
                            if isCompleted {
                                cell.playVideoView.imgView.isHidden = true
                                cell.playVideoView.playerLayer.player?.play()
                                viewModel.isDisplayed = true
                            }
                            
                        }
                        
                    }
                    
                    if viewModel.videoUrl == nil {
                        cell.slider.isHidden = true
                    }
                    else {
                        cell.slider.isHidden = false
                    }
                    
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .title(title):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkTitleTVCell", for: indexPath) as? CheckTitleTVCell {
                    
                    cell.titleLbl.text = title
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .evaluates(evaluations):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkEvaluateRecipeTVCell", for: indexPath) as? CheckEvaluateRecipeTVCell {
                    
                    cell.evaluations = evaluations
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .genres(genre):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkGenresTVCell", for: indexPath) as? CheckGenresTVCell {
                    
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
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkUserTVCell", for: indexPath) as? CheckPublisherTVCell {
                    
                    cell.user = user
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .timeAndServing(time, serving):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkTimeNServingTVCell", for: indexPath) as? CheckTimeNServingTVCell {
                    
                    var timeString = "\(time) mins"
                    
                    if time > 60 {
                        timeString = "\(time / 60) hours \(time % 60) mins"
                    }
 
                    cell.timeLbl.text = timeString
                    cell.serveLbl.text = "\(serving) serving"
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
            case let .ingredients(ingredient):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkIngredientTVCell", for: indexPath) as? CheckIngredientTVCell {
                    
                    cell.ingredient = ingredient
                    cell.configure(ingredient: ingredient)
                    cell.selectionStyle = .none
                
                    
                    return cell
                }
                
            case let .instructions(instruction):
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkInstructionTVCell", for: indexPath) as? CheckInstructionTVCell {
                    
                    cell.instruction = instruction
                    cell.configure(instruction: instruction)
                    cell.selectionStyle = .none

                    return cell
                }
                
            }
            
            return UITableViewCell()
            
        }
        
        dataSource.titleForHeaderInSection = { ds, section -> String? in
            return ds[section].title
            
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
}


extension CheckCreatedRecipeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 444
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
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if viewModel.videoUrl != nil {
            
            guard let videoCell = (cell as? CheckMainImageTVCell) else { return }
            
            videoCell.playVideoView.player?.pause()
            videoCell.playVideoView.player = nil
            videoCell.playVideoView.imgView.isHidden = false
            videoCell.playVideoView.imgView.alpha = 1.0
            
        }
    }
    
}


