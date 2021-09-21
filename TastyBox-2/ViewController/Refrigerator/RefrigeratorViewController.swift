//
//  RefrigeratorViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import UIKit
import Firebase

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
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        
//        tableView.allowsMultipleSelectionDuringEditing = true
//        self.searchBar.delegate = self
//        tableView.delegate = self
//        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
//        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = false
        
        
//        dataManager.getRefrigeratorDetail(userID: uid)
//        dataManager.delegate = self
        SetUpAddBtn()

//        addButton = UIBarButtonItem(title:  "＋", style: .plain, target: self, action: #selector(add))
        editButton = UIBarButtonItem(title:  "Edit", style: .plain, target: self, action: #selector(edit))
        deletebutton = UIBarButtonItem(title:  "Delete", style: .plain, target: self, action:
            #selector(deleteRows))
//        self.navigationItem.rightBarButtonItems = [addButton, editButton]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        dataManager.getRefrigeratorDetail(userID: uid)
    }
    
    func bindViewModel() {
       
//        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: IngredientTableViewCell.identifier,
//                                          cellType: IngredientTableViewCell.self)) { row, element, cell in
////            cell.configure(item: element)
//            cell.amountLbl.text = "大さじ１"
//            cell.nameLbl.text = "砂糖"
//        }
//        .disposed(by: viewModel.disposeBag)
        
        addBtn.rx.action = viewModel.toAddItem()

    }
    
    
    @objc func edit() {
        
        //
        if self.tableView.isEditing == false {
            setEditing(true, animated: true)
            self.tableView.isEditing = true
            editButton.title = "Done"
//            tableView.allowsMultipleSelectionDuringEditing = true
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

extension RefrigeratorViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        if tableView.isEditing {
//            return .delete
//        }
//        return .none
//    }
//}
}



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
