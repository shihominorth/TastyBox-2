//
//  RefrigeratorViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import UIKit
import Firebase
import RxSwift

class RefrigeratorViewController: UIViewController, BindableType {
    
    typealias ViewModelType = RefrigeratorVM
    var viewModel: RefrigeratorVM!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    
    
    var deletebutton = UIBarButtonItem()
    var editButton = UIBarButtonItem()
    var doneBtn = UIBarButtonItem()
    
    var mapBtn = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItems = [editButton, mapBtn]
        
        setUpAddBtn()
        setUpTableView()
        setUpEditBtn()
        setUpKeyboard()
        
        editButton.image = UIImage(systemName: "slider.horizontal.3")
        mapBtn.image = UIImage(systemName: "map")
        
        searchBar.returnKeyType = .done
        searchBar.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        tableView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        
        viewModel.searchingItem()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        viewModel.getItems(listName: .refrigerator)
            .subscribe(onNext: { [unowned self] isGottenItem in
                
                showSearchedResult()
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.moveItems()
    }
    
    
    func bindViewModel() {
        
        addBtn.rx.action = viewModel.toAddItem()
        
        viewModel.isTableViewEditable
            .bind(to: self.addBtn.rx.isHidden).disposed(by: viewModel.disposeBag)
        viewModel.isSelectedCells
            .bind(to: self.deletebutton.rx.isEnabled).disposed(by: viewModel.disposeBag)
        
        
        searchBar.rx.text.orEmpty.bind(to: viewModel.searchingText).disposed(by: viewModel.disposeBag)
        
        viewModel.observableItems
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: viewModel.disposeBag)
    }
    
    func setUpTableView() {
        
        let footerView = UIView()
        tableView.tableFooterView = footerView
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 155, right: 0)

        //MARK: why is the background of cell is grey when the cell is selected?
        // make it grey before tableview.rx.itemSelected....
        tableView.rx.itemSelected
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
                
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self] indexPath in
                
                
                if self.tableView.isEditing {
                    
                    //                    tableView.cellForRow(at: indexPath)?.backgroundColor = .white
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
            .subscribe(onNext: { [unowned self] indexPath in
                
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
                
            
            })
            .disposed(by: viewModel.disposeBag)
        
        
        tableView.rx.itemDeleted
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
                
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { [unowned self] indexPath in
                
                
                self.viewModel.deleteItem(index: indexPath.row)
                    .subscribe(onNext: { isDeleted in
                        
                        if isDeleted {
                            self.showSearchedResult()
                        }
                  
                    })
                    .disposed(by: viewModel.disposeBag)
                
               

            })
            .disposed(by: viewModel.disposeBag)
        
        tableView.rx.didScroll
            .observe(on: MainScheduler.asyncInstance)
            .catch { err in
                
                let err = err as NSError
                print(err)
                
                return .empty()
            }
            .subscribe(onNext: { _ in
                self.searchBar.endEditing(true)

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
                
                self.navigationItem.titleView = nil
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
                    let sortedPaths = indexPaths.sorted { $0.row > $1.row }
                    
                    if viewModel.searchingTemp.isEmpty {
                        
                        sortedPaths.forEach { indexPath in
                        
                            
                            let ingredient = DeletingIngredient(index: indexPath.row, item: self.viewModel.items[indexPath.row])
                            self.viewModel.deletingTemp.append(ingredient)
                        }
                    }
                    else {
                        
                        sortedPaths.forEach { indexPath in
                            
                            guard let index = self.viewModel.items.firstIndex(of: self.viewModel.searchingTemp[indexPath.row]) else {
                                return
                            }
                            
                            let ingredient = DeletingIngredient(index: Int(index), item: self.viewModel.searchingTemp[indexPath.row])
                            self.viewModel.deletingTemp.append(ingredient)
                        }
                    }
                    
                    
                    
                    self.viewModel.deleteItems()
                    
                    self.showSearchedResult()
                    
                    
                }
                
                self.tableView.setEditing(false, animated: true)
                
                self.navigationItem.titleView = searchBar
                self.navigationItem.rightBarButtonItems = [editButton, mapBtn]
                
                self.viewModel.isTableViewEditable.accept(false)
                self.viewModel.isSelectedCells.accept(false)
                
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        doneBtn.rx.tap
            .catch { err in
                print(err)
                return .empty()
            }
            .subscribe(onNext: { [unowned self] element in
                
                self.navigationItem.rightBarButtonItems = [editButton, mapBtn]
                self.navigationItem.titleView = searchBar
                self.tableView.setEditing(false, animated: true)
                
                self.viewModel.isTableViewEditable.accept(false)
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    
    
    
    fileprivate func setUpAddBtn() {
        
        addBtn.clipsToBounds = true
        addBtn.layer.cornerRadius = addBtn.frame.width / 2
        
    }
    
    func setUpKeyboard() {
        
        let _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe ( onNext: { [unowned self] notification in
                
                
                self.navigationItem.setHidesBackButton(true, animated: true)
                self.navigationItem.rightBarButtonItems?.removeAll()
                
                searchBar.showsCancelButton = true
                
            })
        
        let _ = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe ( onNext: { [unowned self] notification in
                
                self.navigationItem.setHidesBackButton(false, animated: true)
                self.navigationItem.rightBarButtonItems = [editButton, mapBtn]
                searchBar.showsCancelButton = false
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    if self.view.frame.origin.y != 0 {
                        self.view.frame.origin.y = 0
                    }
                })
            })
    }
    
    fileprivate func showSearchedResult() {

        searchBar.rx.text.orEmpty
            .subscribe(onNext: { [unowned self] text in
                
                if text.isNotEmpty {
                    self.viewModel.searchingText.accept(text)
                }
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                
                
            })
            .disposed(by: viewModel.disposeBag)
    }
    
}



extension RefrigeratorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            // 編集処理を記述
            self.viewModel.toEditItem(index: indexPath.row)
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // 削除処理
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (action, view, completionHandler) in
            //削除処理を記述
            
            
            self.viewModel.deleteItem(index: indexPath.row)
                .subscribe(onNext: { isDeleted in
                    
                    if isDeleted {
                        self.showSearchedResult()
                    }
              
                })
                .disposed(by: viewModel.disposeBag)
            
           
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension

    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.viewModel.isTableViewEditable.accept(true)

    }
 
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.viewModel.isTableViewEditable.accept(false)
    }
}


extension RefrigeratorViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}


extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
