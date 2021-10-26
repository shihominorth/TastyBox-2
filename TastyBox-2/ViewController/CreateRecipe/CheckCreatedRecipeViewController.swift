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

class CheckCreatedRecipeViewController: UIViewController, BindableType {
 

    typealias ViewModelType = CheckRecipeVM
    var viewModel: CheckRecipeVM!

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: RxTableViewSectionedReloadDataSource<RecipeItemSectionModel>!
    
    var playerItem: AVPlayerItem!
    var playerLooper: AVPlayerLooper!
    var player: AVQueuePlayer!
    var layerPlayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       
        if let url = viewModel.url {
            
            let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            
            self.playerItem = AVPlayerItem(url: url)
            self.player =  AVQueuePlayer(playerItem: self.playerItem)
            self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
            
            self.player.addObserver(self, forKeyPath: "actionAtItemEnd", options: [.new], context: nil)
            self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: [.new], context: nil)
            
           
           let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CheckMainImageTVCell
            cell.playVideoView.playerLayer.player = self.player
            cell.playVideoView.playerLayer.player?.play()
        
        }
     
        
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
                        print("top is row 0")
                    }
                }
                
               

//                self.tableView.indexPathsForRows(in: CGPoint(x: 0.0, y: <#T##CGFloat#>))

            })
            .disposed(by: viewModel.disposeBag)

    }
    
    
    
    
    func setUpDataSource() {
        
        dataSource = RxTableViewSectionedReloadDataSource<RecipeItemSectionModel> { dataSource, tableView, indexPath, element in
            
            switch dataSource[indexPath] {
            
            case let .imageData(data, url):
                
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "checkMainTVCell", for: indexPath) as? CheckMainImageTVCell {
                    
                    cell.imgData = data
                    cell.videoURL = url
                    
//                    cell.setUpImageView(data: data)
//                    if let url = url {
//
//                        cell.playVideoView.playerLayer.player = avPlayer
//                        cell.playVideoView.playerLayer.player?.play()
//
//                    }
                    let cellRect = tableView.rectForRow(at: indexPath)
                    let cellRectInView = tableView.convert(cellRect, to: self.tableView.superview)
                    print(cellRectInView)
                  
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
    
    func setUpPlayVideoView() {
        
//        self.playView = PlayVideoView()
//        playView.frame = view.bounds
        
      
       
//        setUpSlider()
//
//
//        tap = UITapGestureRecognizer()
//
//        tap.rx.event
//            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
//            .asDriver { err in
//
//                print(err)
//
//                return Driver.empty()
//            }
//            .asObservable()
//            .withLatestFrom(viewModel.isHiddenPlayingViewRelay)
//            .subscribe(onNext: { isHiddden in
//                self.viewModel.isHiddenPlayingViewRelay.accept(!isHiddden)
//            })
//            .disposed(by: viewModel.disposeBag)
//
//
//        self.playView.addGestureRecognizer(tap)
//
//        view.addSubview(self.playView)
        
    }
    
    func createPlayerLayer() -> AVPlayerLayer {
        
        let layer = AVPlayerLayer(player: self.player)
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspect
        
        return layer
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            
//            playView.indicator.stopAnimating()
            
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


