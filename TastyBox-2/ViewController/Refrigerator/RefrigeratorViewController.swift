//
//  RefrigeratorViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class RefrigeratorViewController: UIViewController, BindableType {
    
    typealias ViewModelType = RefrigeratorVM
    var viewModel: RefrigeratorVM!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    var ingredients: [RefrigeratorItem] = []
    
    let db = Firestore.firestore()
//    let dataManager = IngredientRefrigeratorDataManager()
    var readyDelete = false
    
    
    let searchBar = UISearchBar()
    
    var deletebutton = UIBarButtonItem()
//    var addButton = UIBarButtonItem()
    var editButton = UIBarButtonItem()
    var doneBtn = UIBarButtonItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = editButton

//        guard let uid = Auth.auth().currentUser?.uid else { return }
        
//        tableView.allowsMultipleSelectionDuringEditing = true
//        self.searchBar.delegate = self
//        tableView.delegate = self
//        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
//        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.delegate = self

        
//        dataManager.getRefrigeratorDetail(userID: uid)
//        dataManager.delegate = self
        SetUpAddBtn()
        setUpTableView()
        editButton.image = UIImage(systemName: "slider.vertical.3")
//        deletebutton = UIBarButtonItem(title:  "Delete", style: .plain, target: self, action:
//            #selector(deleteRows))
        
//        self.tableView.allowsMultipleSelectionDuringEditing = true

    }
    
    override func viewWillAppear(_ animated: Bool) {

        viewModel.getItems(listName: .refrigerator)
    }
    
    func bindViewModel() {
       
        viewModel.getItems(listName: .refrigerator)
        
        viewModel.observableItems.bind(to: tableView.rx.items(cellIdentifier: IngredientTableViewCell.identifier,
                                          cellType: IngredientTableViewCell.self)) { row, element, cell in
            cell.configure(item: element)

        }
        .disposed(by: viewModel.disposeBag)
        
        addBtn.rx.action = viewModel.toAddItem()
        
        viewModel.isTableViewEditable
            .bind(to: self.addBtn.rx.isHidden).disposed(by: viewModel.disposeBag)
        viewModel.isSelectedCells
            .bind(to: self.deletebutton.rx.isEnabled).disposed(by: viewModel.disposeBag)
        
        setUpEditBtn()
    }
    
    func setUpTableView() {


        tableView.rx.itemSelected
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
               
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self] indexPath in


                if self.tableView.isEditing {
                    
                    tableView.cellForRow(at: indexPath)?.backgroundColor = .white
                   
                    self.viewModel.isSelectedCells.accept(true)

                } else {
                    
                    self.viewModel.toEditItem(index: indexPath.row)
                    self.tableView.deselectRow(at: indexPath, animated: true)
                
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        
        
        tableView.rx.itemDeselected
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
               
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self] event in
                
                if self.tableView.isEditing {
                    
                    guard let _ = tableView.indexPathsForSelectedRows else {
                        self.viewModel.isSelectedCells.accept(false)
                        return
                    }
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
       
        tableView.rx.itemMoved
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
               
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self]  event in
                
                let movingItem = viewModel.items[event.sourceIndex.row]
                
                self.viewModel.items.remove(at: event.sourceIndex.row)
                self.viewModel.items.insert(movingItem, at: event.destinationIndex.row)
                
                self.viewModel.observableItems.onNext(self.viewModel.items)
                
                
            })
            .disposed(by: viewModel.disposeBag)
     
        
        tableView.rx.itemDeleted
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
               
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { indexPath in
                             
                self.viewModel.items.remove(at: indexPath.row)
                self.viewModel.observableItems.onNext(self.viewModel.items)
                
            })
            .disposed(by: viewModel.disposeBag)
        
      
    }
    
    
    
    func setUpEditBtn() {
        
        deletebutton.title = "Delete"
        doneBtn.title = "Done"
        tableView.allowsMultipleSelectionDuringEditing = true

        // make table view is editable
        editButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
               
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self]  _ in
              
                self.navigationItem.rightBarButtonItems = [doneBtn, deletebutton]
                self.tableView.setEditing(true, animated: true)
                self.viewModel.isTableViewEditable.accept(true)
            })
            .disposed(by: viewModel.disposeBag)
        
       
        // delete selected rows
        deletebutton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
               
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self]  _ in
                
                
                if let indexPaths = tableView.indexPathsForSelectedRows  {
                    //Sort the array so it doesn't cause a crash depending on your selection order.
                    let sortedPaths = indexPaths.sorted {$0.row > $1.row}
                    
                    sortedPaths.forEach { indexPath in
                        
                        self.viewModel.items.remove(at: indexPath.row)
                       
                    }
                    
                    self.viewModel.observableItems.onNext(self.viewModel.items)
                   
                }
                
                
                self.tableView.setEditing(false, animated: true)
                self.navigationItem.rightBarButtonItems = [editButton]
                self.viewModel.isTableViewEditable.accept(false)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        doneBtn.rx.tap
            .catch { err in
                print(err)
                return .empty()
            }
            .subscribe(onNext: { [unowned self] element in

                self.navigationItem.rightBarButtonItems = [editButton]
                self.tableView.setEditing(false, animated: true)

            })
            .disposed(by: viewModel.disposeBag)
    }
    
    @objc func edit() {
        
        //
        if self.tableView.isEditing == false {
            setEditing(true, animated: true)
            self.tableView.isEditing = true
            editButton.title = "Done"
            self.navigationItem.rightBarButtonItems =  [editButton, deletebutton]
            
            
        } else {
            setEditing(false, animated: true)
            self.tableView.isEditing = false
            
            editButton.title = "Edit"
            self.navigationItem.rightBarButtonItems =  [editButton]
            
        }
        
    }
    
    
    fileprivate func SetUpAddBtn() {

        addBtn.clipsToBounds = true
        addBtn.layer.cornerRadius = addBtn.frame.width / 2
       
        
    }
    
    @objc private func deleteRows() {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        
        // 配列の要素削除で、indexの矛盾を防ぐため、降順にソートする
        let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
        
        for indexPathList in sortedIndexPaths {
//            dataManager.deleteData(name: ingredients[indexPathList.row].name, indexPath: indexPathList)
            ingredients.remove(at: indexPathList.row) // 選択肢のindexPathから配列の要素を削除
        }
        
        // tableViewの行を削除
        tableView.deleteRows(at: sortedIndexPaths, with: .automatic)
        
    }
    
//    @objc func add() {
//        let vc = storyboard?.instantiateViewController(identifier: "editIngredientsRefrigerator") as! AddingIngredientRefrigeratorViewController
//        vc.itemIsEmpty = true
//        vc.delegate = self
//
//        guard self.navigationController?.topViewController == self else { return }
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    //    override func setEditing(_ editing: Bool, animated: Bool) {
    //        super.setEditing(editing, animated: animated)
    //        tableView.setEditing(editing, animated: true)
    //        //        navigationItem.rightBarButtonItems?.remove(at: 1)
    //    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if tableView.isEditing {
            if identifier == "editItemRefrigerator" {
                return false
            }
        }
        return true
    }
    
}

extension RefrigeratorViewController: UITableViewDelegate {

//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            viewModel.items.remove(at: indexPath.row)
            viewModel.observableItems.onNext(viewModel.items)

            tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

}

//final class MyDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
//
//    typealias Element = [RefrigeratorItem]
//    var items = [RefrigeratorItem]()
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: IngredientTableViewCell.identifier,
//                                                 for: indexPath) as! IngredientTableViewCell
//        let item = items[indexPath.row]
//        cell.configure(item: item)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, observedEvent: Event<[RefrigeratorItem]>) {
//        Binder(self) { dataSource, element in
//            guard let items = element.element else { return }
//            dataSource.items = items
//            tableView.reloadData()
//        }
//        .onNext(observedEvent)
//    }
//}

//
//extension RefrigeratorViewController: UITableViewDataSource {
//    
//    //    func numberOfSections(in tableView: UITableView) -> Int {
//    //        return 2
//    //    }
//    //
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        //        if section == 0 {
//        //            return 1
//        //        }
//        return ingredients.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
////        let cell = (tableView.dequeueReusableCell(withIdentifier: "ingredient", for: indexPath) as? IngredientsTableViewCell)!
////
////        // Configure the cell...
////        cell.contentView.backgroundColor = .white
////        cell.nameIngredientsLabel.text = ingredients[indexPath.row].name
////        cell.amountIngredientsLabel.text = ingredients[indexPath.row].amount
////
//        
//        return cell
//        //        }
//        //
//        //        return UITableViewCell()
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        
//        //        if tableView.allowsMultipleSelectionDuringEditing == true {
////        let cell = (tableView.cellForRow(at: indexPath) as? IngredientsTableViewCell)!
////        if tableView.isEditing == false {
////            let addVC = storyboard?.instantiateViewController(identifier: "editIngredientsRefrigerator") as! AddingIngredientRefrigeratorViewController
////            //                    let item = ingredients[indexPath.row]//shoppingList.list[indexPath.row]
////            //                                        addVC.item = item
////            addVC.indexPath = indexPath
////            addVC.delegate = self as AddingIngredientRefrigeratorViewControllerDelegate
////            addVC.itemIsEmpty = false
////            addVC.name = ingredients[indexPath.row].name
////            addVC.amount = ingredients[indexPath.row].amount
////
////            guard self.navigationController?.topViewController == self else { return }
////            navigationController?.pushViewController(addVC, animated: true)
////        } else {
////
////        }
//        
////        if let selectedRows = tableView.indexPathsForSelectedRows {
////            if selectedRows.count == 0 {
////                self.navigationItem.rightBarButtonItems?.append(deletebutton)
////            }
////
////        }
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        
//    }
//    
//}





//extension RefrigeratorViewController: getIngredientRefrigeratorDataDelegate {
//    func gotData(ingredients: [IngredientRefrigerator]) {
//        self.ingredients = ingredients
//        tableView.reloadData()
//    }
//
//
//}
//
//extension RefrigeratorViewController: AddingIngredientRefrigeratorViewControllerDelegate {
//    func editIngredient(controller: AddingIngredientRefrigeratorViewController, name: String, amount: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//       dataManager.editIngredient(name: name, amount: amount, userID: uid)
//        dataManager.getRefrigeratorDetail(userID: uid)
//        tableView.reloadData()
//    }
//
//    func addIngredient(controller: AddingIngredientRefrigeratorViewController, name: String, amount: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//         dataManager.addIngredient(name: name, amount: amount, userID: uid)
//        print(ingredients)
//        dataManager.getRefrigeratorDetail(userID: uid)
//        tableView.reloadData()
//    }
//
//}
//
//extension RefrigeratorViewController: UISearchBarDelegate {
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        var temp: [RefrigeratorItem] = []
//
//        if searchBar.text != "" {
//
//            let text = searchBar.text!.lowercased()
//
//            for ingredient in ingredients {
//                let name = ingredient.name.lowercased()
//
//                if name.contains(text){
//                    temp.append(ingredient)
//                }
//            }
//
//            ingredients.removeAll()
//            ingredients = temp
//
//            tableView.reloadData()
//
//        } else {
//            dataManager.getRefrigeratorDetail(userID: uid)
//            tableView.reloadData()
//        }
//
//    }
//
//    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.endEditing(true)
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        self.searchBar.endEditing(true)
//        navigationController?.popViewController(animated: true)
//    }
//
//}


extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
