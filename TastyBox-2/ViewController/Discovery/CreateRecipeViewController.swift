//
//  CreateRecipeViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import AVFoundation
import UIKit
import Photos
import PhotosUI
import RxCocoa
import RxSwift

class CreateRecipeViewController: UIViewController, BindableType {
    
    
    typealias ViewModelType = CreateRecipeVM
    
    var viewModel: CreateRecipeVM!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.viewModel.appendNewIngredient()
        self.viewModel.appendNewInstructions()
        
        setUpTableView()
    }
    
    
    func bindViewModel() {
        
        //        self.viewModel.playVideo()
        //        self.addedVideo()
        
    }
    
    fileprivate func setUpTableView() {
        
        self.tableView.allowsSelectionDuringEditing = true
        
        tableView.rx.didScroll
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
                
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self] _ in
                
                if tableView.isTracking {
                    self.tableView.endEditing(true)
                }
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    //    func addedVideo() {
    //
    //        viewModel.isAddedSubject
    //            .filter { $0 }
    //            .withLatestFrom(viewModel.videoPlaySubject)
    //            .subscribe(onNext: { [unowned self] url in
    //
    //                if let data = self.getThumbnailImage(forUrl: url)?.convertToData() {
    //                    self.viewModel.thumbnailImgDataSubject.onNext(data)
    //                }
    //
    //            })
    //            .disposed(by: viewModel.disposeBag)
    //
    //    }
    
    
    
}

extension CreateRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 4:
            return viewModel.ingredients.count
            
        case 6:
            return viewModel.instructions.count
            
        default:
            break
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editMainImage", for: indexPath) as? EditMainImageTVCell {
                
                cell.collectionView.rx.itemSelected
                    .filter { $0.row == 0 }
                    .do(onNext: { [unowned self] _ in self.viewModel.toImagePicker() })
                    .flatMap { [unowned self] _ in self.viewModel.getImage() }
                    .bind(to: cell.mainImgDataSubject)
                    .disposed(by: cell.disposeBag)
                
                cell.collectionView.rx.itemSelected
                    .filter { $0.row == 1 }
                    .do(onNext: { [unowned self] _ in self.viewModel.toVideoPicker() })
                    .flatMap { [unowned self] _ in self.viewModel.getVideoUrl() }
                    .observe(on: MainScheduler.instance)
                    .do(onNext:  { [unowned self] in self.viewModel.playVideo(url: $0) })
                    .flatMap { [unowned self] in self.viewModel.getThumbnail(url: $0)}
                    .bind(to: cell.thumbnailDataSubject)
                    .disposed(by: cell.disposeBag)
                
                        
                return cell
            }
            
        case 1:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editTitle", for: indexPath) as? EditTitleRecipeTVCell {
                
                viewModel.keyboardOpen
                    .subscribe(onNext: { [weak self] notification in
                        
                        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let viewHeight =  self?.view.frame.height {
                            
                            if cell.txtField.isFirstResponder  {
                                
                                let cellRect = tableView.rectForRow(at: indexPath)
                                let cellRectInView = tableView.convert(cellRect, to: self?.navigationController?.view)
                                
                                if cellRectInView.origin.y + cellRect.height >= viewHeight - keyboardSize.height {
                                    tableView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height), animated: true)
                                }
                                
                            }
                            
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            
        case 2:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editTimeNserving", for: indexPath) as? EditTimeNSearvingTVCell {
                
                viewModel.keyboardOpen
                    .subscribe(onNext: { [weak self] notification in
                        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let viewHeight =  self?.view.frame.height {
                            
                            if cell.timeTxtField.isFirstResponder || cell.servingTxtField.isFirstResponder {
                                
                                let cellRect = tableView.rectForRow(at: indexPath)
                                let cellRectInView = tableView.convert(cellRect, to: self?.navigationController?.view)
                                
                                if cellRectInView.origin.y + cellRect.height >= viewHeight - keyboardSize.height {
                                    tableView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height), animated: true)
                                }
                            }
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                
                return cell
            }
            
        case 3:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editHeaderIngredients", for: indexPath) as? EditIngredientsHeaderCell {
                
                cell.addBtn.rx.tap
                    .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .asObservable()
                    .flatMap { [unowned self] in self.viewModel.isAppendNewIngredient() }
                    .subscribe(onNext: { [unowned self] isAppended in
                        
                        tableView.insertRows(at: [IndexPath(row: self.viewModel.ingredients.count - 1, section: 4)], with: .automatic)
                        
                    }, onError: { err in
                        print(err)
                    })
                    .disposed(by: cell.disposeBag)
                
                
                cell.editbtn.rx.tap
                    .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .asObservable()
                    .flatMap { [unowned self] in self.viewModel.setIsEditableTableViewRelay() }
                    .subscribe(onNext: { [unowned self] element in
                        
                        
                        if !self.viewModel.isEditableIngredientsRelay.value && !self.viewModel.isEditInstructionsRelay.value {
                            
                            tableView.setEditing(false, animated: true)
                            
                        }
                        else {
                            
                            tableView.setEditing(false, animated: true)
                            tableView.setEditing(true, animated: true)
                        }
                        
                    }, onError: { err in
                        print(err)
                    })
                    .disposed(by: cell.disposeBag)
                
                
                return cell
            }
            
        case 4:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editingredients", for: indexPath) as? EditIngredientsTVCell {
                
                viewModel.keyboardOpen
                    .subscribe(onNext: { [weak self] notification in
                        
                        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let viewHeight =  self?.view.frame.height {
                            
                            if cell.nameTxtField.isFirstResponder || cell.amountTxtField.isFirstResponder {
                                
                                let cellRect = tableView.rectForRow(at: indexPath)
                                let cellRectInView = tableView.convert(cellRect, to: self?.navigationController?.view)
                                
                                if cellRectInView.origin.y + cellRect.height >= viewHeight - keyboardSize.height {
                                    tableView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height), animated: true)
                                }
                            }
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            
        case 5:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editHeaderInstructions", for: indexPath) as? EditInstructionHeaderTVCell {
                
                cell.addBtn.rx.tap
                    .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .asObservable()
                    .flatMap { [unowned self] in self.viewModel.isAppendNewInstructions() }
                    .subscribe(onNext: { [unowned self] isAppended in
                        
                        tableView.insertRows(at: [IndexPath(row: self.viewModel.instructions.count - 1, section: 6)], with: .automatic)
                        
                    }, onError: { err in
                        print(err)
                    })
                    .disposed(by: cell.disposeBag)
                
                
                cell.editBtn.rx.tap
                    .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .asObservable()
                    .flatMap { [unowned self] in self.viewModel.setIsEditInstructionRelay() }
                    .subscribe(onNext: { [unowned self] _ in
                        
                        if !self.viewModel.isEditableIngredientsRelay.value && !self.viewModel.isEditInstructionsRelay.value {
                            
                            tableView.setEditing(false, animated: true)
                            
                        }
                        else {
                            
                            tableView.setEditing(false, animated: true)
                            tableView.setEditing(true, animated: true)
                        }
                        
                        
                    }, onError: { err in
                        print(err)
                        
                    })
                    .disposed(by: cell.disposeBag)
                
                
                
                return cell
            }
            
        case 6:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editInstructions", for: indexPath) as? EditInstructionTVCell {
                
                cell.stepNumLbl.text = "Step \(indexPath.row + 1)"
                
                let data = self.viewModel.instructions[indexPath.row].imageData
                cell.imgSubject.onNext(data)
               
                viewModel.keyboardOpen
                    .subscribe(onNext: { [weak self] notification in
                        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let viewHeight =  self?.view.frame.height{
                            
                            if cell.txtView.isFirstResponder  {
                                
                                
                                let cellRect = tableView.rectForRow(at: indexPath)
                                let cellRectInView = tableView.convert(cellRect, to: self?.navigationController?.view)
                                
                                
                                
                                if cellRectInView.origin.y + cellRect.height >= viewHeight - keyboardSize.height {
                                    
                                    tableView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height), animated: true)
                                    
                                }
                            }
                            
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.txtView.rx.text.subscribe(onNext: { text in
                    
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                }).disposed(by: cell.disposeBag)
                
                cell.tapped
                    .flatMap { [unowned self] in self.viewModel.instructionsToImagePicker(index: indexPath.row) }
                    .bind(to: cell.imgSubject)
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
            
        case 0:
            return tableView.frame.width
            //
            //        case 6:
            //            return UITableView.automaticDimension
            
        default:
            return UITableView.automaticDimension
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 6 {
            
            return 120
        }
        
        return UITableView.automaticDimension
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if self.viewModel.isEditableIngredientsRelay.value && self.viewModel.isEditInstructionsRelay.value {
            
            switch indexPath.section {
            case 4, 6:
                return true
                
            default:
                break
            }
            
        }
        else if self.viewModel.isEditableIngredientsRelay.value && indexPath.section == 4 {
            
            return true
            
        }
        else if self.viewModel.isEditInstructionsRelay.value && indexPath.section == 6 {
            
            return true
        }
        
        return false
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 削除処理
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (action, view, completionHandler) in
            //削除処理を記述
            
            switch indexPath.section {
            case 4:
                self.viewModel.ingredients.remove(at: indexPath.row)
               
            case 6:
                self.viewModel.instructions.remove(at: indexPath.row)
               
            default:
                break
            }
            
            switch indexPath.section {

            case 4, 6:
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)

            default:
                break
            }

            
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
