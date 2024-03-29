//
//  CreateRecipeViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2022-03-08.
//

import AVFoundation
import Action
import UIKit
import Photos
import PhotosUI
import RxCocoa
import RxSwift

class CreateRecipeViewController: UIViewController, BindableType {

    typealias ViewModelType = CreateRecipeVM
    
    var viewModel: CreateRecipeVM!
    
    @IBOutlet weak var tableView: UITableView!
    
    var nextBtn = UIBarButtonItem()
    var cancelBtn = UIBarButtonItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.viewModel.appendNewIngredient()
        self.viewModel.appendNewInstructions()
        
        setUpTableView()
        
        nextBtn.title = "Next"
        cancelBtn.title = "Cancel"
        
        self.navigationItem.rightBarButtonItem = nextBtn
//        self.navigationItem.leftBarButtonItem = cancelBtn
        
    }
    
    
    func bindViewModel() {
        
        nextBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .withLatestFrom(viewModel.combinedRequirements)
            .flatMap { [unowned self]  isMainImgValid, isTitleValid, isTimeValid, isServingValid in
                
                self.viewModel.isFilledRequirement(isMainImgValid: isMainImgValid, isTitleValid: isTitleValid, isTimeValid: isTimeValid, isServingValid: isServingValid)
                
            }
            .filter { $0 }
            .withLatestFrom(viewModel.combinedIngredientAndInstructionValidation)
            .flatMap { [unowned self] isIngredientValid, isInstructionValid in
                
                self.viewModel.isIngredientsAndInstructions(isIngredientValid: isIngredientValid, isInstructionValid: isInstructionValid)
                
            }
            .filter { $0 }
            .subscribe(onNext: { [unowned self] isFilled in
                
                self.viewModel.goToNext()
                
            })
            .disposed(by: viewModel.disposeBag)
        
        cancelBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .subscribe(onNext: { _ in
                
                self.viewModel.pop()
                
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.keyboardClose
            .subscribe(onNext: { [unowned self] _ in
                
                if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
    }
    
    fileprivate func setUpTableView() {
        
        self.tableView.allowsSelectionDuringEditing = true
        
        tableView.tableFooterView = UIView()
        
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
    
}

extension CreateRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 6:
            return viewModel.ingredients.count
            
        case 8:
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
                
                
                viewModel.mainImgDataSubject
                    .bind(to: cell.mainImgDataSubject)
                    .disposed(by: cell.disposeBag)
                
                viewModel.thumbnailImgDataSubject
                    .bind(to: cell.thumbnailDataSubject)
                    .disposed(by: cell.disposeBag)
                
//
                let collectionViewTapped = cell.collectionView.rx.itemSelected.share(replay: 1, scope: .forever)
//
                collectionViewTapped
                    .filter { $0.row == 0 }
                    .subscribe(on: MainScheduler.instance)
                    .withLatestFrom(viewModel.mainImgDataSubject)
                    .subscribe(onNext: { [unowned self] data in

                        switch viewModel.mainImgKind {
                        
                        case .image:
                            self.viewModel.toSelectDigitalContentsVC(kind: .recipeMain(.image))
                        
                        case .video:
                            self.viewModel.toSelectThumbnail(imageData: data)
                        default:
                            break
                        }
                        
                      
//                        self.viewModel.toImagePicker()

                    })
                    .disposed(by: cell.disposeBag)
//
//
//                self.viewModel.mainImgDataSubject
//                    .skip(1)
//                    .bind(to: cell.mainImgDataSubject)
//                    .disposed(by: cell.disposeBag)
//
//                collectionViewTapped
//                    .filter { $0.row == 1 }
//                    .observe(on: MainScheduler.instance)
//                    .subscribe(onNext: { [unowned self] _ in
//
//                        self.viewModel.toVideoPicker()
//
//                    })
//                    .disposed(by: cell.disposeBag)
//
//                self.viewModel.videoPlaySubject
//                    .skip(1)
//                    .observe(on: MainScheduler.instance)
//                    .subscribe(onNext: { url in
//
//                        self.viewModel.playVideo(url: url)
//
//                    })
//                    .disposed(by: cell.disposeBag)
//
//
//                self.viewModel.isAddedSubject
//                    .filter { $0 }
//                    .withLatestFrom(viewModel.videoPlaySubject)
//                    .flatMapLatest { url in
//                        self.viewModel.getThumbnail(url: url)
//                    }
//                    .bind(to: cell.thumbnailDataSubject)
//                    .disposed(by: cell.disposeBag)
//

                
                
                return cell
            }
            
        case 1:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editTitle", for: indexPath) as? EditTitleRecipeTVCell {
                
                cell.txtField.rx.text.orEmpty
                    .bind(to: viewModel.titleSubject)
                    .disposed(by: cell.disposeBag)
                
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
                
                viewModel.selectedTimeSubject
                    .bind(to: cell.timeTxtField.rx.text.orEmpty)
                    .disposed(by: cell.disposeBag)
                
                let picker = UIPickerView()
              
                picker.delegate = self
                picker.dataSource = self
                
                cell.timeTxtField.inputView = picker
                
                let bar = UIToolbar()
                bar.sizeToFit()
                
                let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
                let endBtn = UIBarButtonItem()
                endBtn.title = "Done"
                
                endBtn.rx.tap
                    .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { _ in
                        
                        cell.timeTxtField.endEditing(true)
                        
                    })
                    .disposed(by: cell.disposeBag)
                
                bar.items = [space, endBtn]
                
                cell.timeTxtField.inputAccessoryView = bar
                cell.servingTxtField.inputAccessoryView = bar
                
                cell.servingTxtField.rx.text.orEmpty
                    .flatMap { text -> Observable<Int> in
                        
                        if let serving = Int(text) {
                            return .just(serving)
                        }
                        
                        return .empty()
                    }
                    .bind(to: viewModel.servingSubject)
                    .disposed(by: cell.disposeBag)
                
                viewModel.keyboardOpen
                    .subscribe(onNext: { [weak self] notification in
                        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let viewHeight =  self?.view.frame.height {
                            
                            if cell.timeTxtField.isFirstResponder || cell.servingTxtField.isFirstResponder {
                                
                                let cellRect = tableView.rectForRow(at: indexPath)
                                let cellRectInView = tableView.convert(cellRect, to: self?.navigationController?.view)
                                
                                if cellRectInView.origin.y + cellRect.height >= viewHeight - keyboardSize.height {
                                    tableView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height + cellRect.height), animated: true)
                                }
                            }
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                
                return cell
            }
            
        case 3:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "isVIPCell", for: indexPath) as? RecipeVIPTVCell {
                
                cell.isVIPSwitch.isOn = false
                
                cell.isVIPSwitch.rx.isOn
                    .bind(to: viewModel.isVIPSubject)
                    .disposed(by: viewModel.disposeBag)
                
                return cell
            }
        case 4:
            
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "selectGenreTVCell", for: indexPath) as? SelectGenreTVCell {
                
                
                cell.setIsSelectedGenre(isSelected: viewModel.selectedGenres.value.exists)
                
                cell.selectBtn.rx.tap
                    .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .asObservable()
                    .withLatestFrom(viewModel.selectedGenres)
                    .subscribe(onNext: { [unowned self] genres in
                        
                        self.viewModel.goToAddGenres(genres: genres)
                        
                    })
                    .disposed(by: viewModel.disposeBag)
                
                return cell
            }
            
        case 5:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editHeaderIngredients", for: indexPath) as? EditIngredientsHeaderCell {
                
                cell.addBtn.rx.tap
                    .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .asObservable()
                    .flatMap { [unowned self] in self.viewModel.isAppendNewIngredient() }
                    .subscribe(onNext: { [unowned self] isAppended in
                        
                        tableView.insertRows(at: [IndexPath(row: self.viewModel.ingredients.count - 1, section: 6)], with: .automatic)
                        
                    }, onError: { err in
                        print(err)
                    })
                    .disposed(by: cell.disposeBag)
                
                
                cell.editBtn.rx.tap
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
                        
                        if cell.editBtn.titleLabel?.text == "Edit" {
                            
                            cell.editBtn.setTitle("Done", for: .normal)
                            
                        }
                        else {
                            cell.editBtn.setTitle("Edit", for: .normal)
                        }
                        
                    }, onError: { err in
                        print(err)
                    })
                    .disposed(by: cell.disposeBag)
                
                
                return cell
            }
            
        case 6:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editingredients", for: indexPath) as? EditIngredientsTVCell {
                
                cell.nameTxtField.rx.text.orEmpty
                    .bind(onNext: { [unowned self] text in
                        
                        self.viewModel.ingredients[indexPath.row].name = text
                        self.viewModel.ingredientsSubject.onNext(self.viewModel.ingredients)
                        
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.amountTxtField.rx.text.orEmpty
                    .bind(onNext: { [unowned self] text in
                        
                        self.viewModel.ingredients[indexPath.row].amount = text
                        self.viewModel.ingredientsSubject.onNext(self.viewModel.ingredients)
                        
                    })
                    .disposed(by: cell.disposeBag)
                
                
                viewModel.keyboardOpen
                    .subscribe(onNext: { [weak self] notification in
                        
                        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let viewHeight =  self?.view.frame.height, let strongSelf = self {
                            
                            if cell.nameTxtField.isFirstResponder || cell.amountTxtField.isFirstResponder {
                                
                                let cellRect = tableView.rectForRow(at: indexPath)
                                let cellRectInView = tableView.convert(cellRect, to: strongSelf.navigationController?.view)
                                
                                if cellRectInView.origin.y + cellRect.height >= viewHeight - keyboardSize.height {
                                    //                                    tableView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height + cellRectInView.height), animated: true)
                                    if strongSelf.view.frame.origin.y == 0 {
                                        strongSelf.view.frame.origin.y -= keyboardSize.height
                                    }
                                    
                                    strongSelf.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                }
                            }
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            
        case 7:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editHeaderInstructions", for: indexPath) as? EditInstructionHeaderTVCell {
                
                
                cell.addBtn.rx.tap
                    .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .asObservable()
                    .flatMap { [unowned self] in self.viewModel.isAppendNewInstructions() }
                    .subscribe(onNext: { [unowned self] isAppended in
                        
                        tableView.insertRows(at: [IndexPath(row: self.viewModel.instructions.count - 1, section: 8)], with: .automatic)
                        
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
                        
                        if cell.editBtn.titleLabel?.text == "Edit" {
                            cell.editBtn.setTitle("Done", for: .normal)
                        }
                        else {
                            cell.editBtn.setTitle("Edit", for: .normal)
                        }
                        
                    }, onError: { err in
                        print(err)
                        
                    })
                    .disposed(by: cell.disposeBag)
                
                
                
                return cell
            }
            
        case 8:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "editInstructions", for: indexPath) as? EditInstructionTVCell {
                
                cell.stepNumLbl.text = "Step \(indexPath.row + 1)"
                
                cell.txtView.rx.text.orEmpty
                    .do(onNext: { text in
                        self.viewModel.instructions[indexPath.row].text = text
                        self.viewModel.instructionsSubject.onNext(self.viewModel.instructions)
                    })
                    .bind(onNext: { [unowned self] text in
                        
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                        
                        
                    })
                        .disposed(by: cell.disposeBag)
                        
                        cell.imgSubject
                        .bind(onNext: { data in
                            
                            let string = data.base64EncodedString()
                            
                            self.viewModel.instructions[indexPath.row].imageURL = string
                            
                            
                        })
                        .disposed(by: cell.disposeBag)
                        
                viewModel.keyboardOpen
                    .subscribe(onNext: { [weak self] notification in
                        
                        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let strongSelf =  self {
                            
                                if cell.txtView.isFirstResponder  {
                                    
                                    if strongSelf.view.frame.origin.y == 0 {
                                        strongSelf.view.frame.origin.y -= keyboardSize.height
                                    }
                                    
                                    strongSelf.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                    
                                }
                                
                        }
                    })
                    .disposed(by: cell.disposeBag)
                        
                cell.tapped
                    .flatMapLatest { [unowned self] in self.viewModel.instructionsToImagePicker(index: indexPath.row) }
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
            
            
        default:
            return UITableView.automaticDimension
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if self.viewModel.isEditableIngredientsRelay.value && self.viewModel.isEditInstructionsRelay.value {
            
            switch indexPath.section {
            case 6, 8:
                return true
                
            default:
                break
            }
            
        }
        else if self.viewModel.isEditableIngredientsRelay.value && indexPath.section == 6 {
            
            return true
            
        }
        else if self.viewModel.isEditInstructionsRelay.value && indexPath.section == 8 {
            
            return true
        }
        
        return false
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 削除処理
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (action, view, completionHandler) in
            //削除処理を記述
            
            switch indexPath.section {
            case 6:
                self.viewModel.ingredients.remove(at: indexPath.row)
                
            case 8:
                self.viewModel.instructions.remove(at: indexPath.row)
                
            default:
                break
            }
            
            switch indexPath.section {
                
            case 6, 8:
                tableView.deleteRows(at: [indexPath], with: .automatic)
                //                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                
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

extension CreateRecipeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0:
            return 24
            
        case 1:
            return 1
            
        case 2:
            return 59
            
        case 3:
            return 1
            
        default:
            break
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center

        switch component {
        case 0, 2:
            label.text = String(row)
           
        case 1:
            label.text = "hours"
            
        case 3:
            label.text = "mins"
        default:
            break
        }
      
     
        return label
    
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let textFiledTxt = self.viewModel.selectedTimeSubject.value
        var txtArr = textFiledTxt.components(separatedBy: " ").filter { $0 != "" }.filter { $0 != "hours" }.filter { $0 != "mins" }

        if textFiledTxt.isEmpty {
            
            if component == 0 {
               
                let txt = "\(row) hours 0 mins"
                self.viewModel.selectedTimeSubject.accept(txt)
            }
            else if component == 2 {
                
                let txt = "0 hours \(row) mins"
                self.viewModel.selectedTimeSubject.accept(txt)
            }
            
        }
        else {
            
            if component == 0 {
                
                if txtArr[0] != "\(row)" {
                    txtArr[0] = "\(row)"
                }
                
            }
            else if component == 2 {
                
                if txtArr[1] != "\(row)" {
                    txtArr[1] = "\(row)"
                }
                
            }
            
            let txt = "\(txtArr[0]) hours \(txtArr[1]) mins"
            self.viewModel.selectedTimeSubject.accept(txt)
            
        }
       
        
    }
    
}

