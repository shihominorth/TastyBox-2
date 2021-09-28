//
//  ShoppinglistVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-26.
//

import Foundation
import Action
import Firebase
import RxCocoa
import RxSwift

class ShoppinglistVM: ViewModelBase {
   
    let sceneCoodinator: SceneCoordinator
    let apiType: RefrigeratorProtocol.Type
    
    var user: FirebaseAuth.User!
    var err = NSError()
    
    let empty = ShoppingItem(name: "___________________empty", amount: "", key: "", isBought: false, order: 0)
    
    var emptyHeight: CGFloat = 140.0
    var hasEmptyCell: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)

    var items: [ShoppingItem] = []
    var searchingTemp:[ShoppingItem] = []
    var deletingTemp:[DeletingIngredient] = []
    
    var observableItems = PublishSubject<[ShoppingItem]>()
    
    var isTableViewEditable = BehaviorRelay<Bool>(value: false)
    var isSelectedCells = BehaviorRelay<Bool>(value: false)
    
    var searchingText = BehaviorRelay<String>(value: "")
    
    lazy var dataSource: RxRefrigeratorTableViewDataSource<ShoppingItem, ShoppinglistTVCell> = {
        
        return RxRefrigeratorTableViewDataSource<ShoppingItem, ShoppinglistTVCell>(identifier: ShoppinglistTVCell.identifier, emptyValue: self.empty) { row, element, cell in
            
            cell.configure(item: element)
            
            cell.checkMarkBtn.rx.tap
                .catch { err in
                    print(err)
                    return .empty()
                }
                .subscribe(onNext: {
                    element.isBought = !element.isBought
                    cell.updateCheckMark(isBought: element.isBought)
                }, onError: { err in
                    print(err)
                })
                .disposed(by: self.disposeBag)
        }
    }()
    
    init(sceneCoodinator: SceneCoordinator, apiType: RefrigeratorProtocol.Type = RefrigeratorDM.self, user: FirebaseAuth.User) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.user = user
    }
    
    func toAddItem() -> CocoaAction {
        
        return CocoaAction { _ in
            
            let index = self.items.count
            let vm =  EditShoppinglistVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: nil, lastIndex: index)
            let vc = IngredientScene.editShoppinglist(vm).viewController()
            
            return self.sceneCoodinator.transition(to: vc, type: .push).asObservable().map { _ in }
        }
    }
    
    func toEditItem(index: Int)  {
        
        var vm :EditItemRefrigeratorVM!
        
        if searchingTemp.isEmpty {
            vm =  EditItemRefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: self.items[index], lastIndex: index)
        }
        else {
            vm =  EditItemRefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: self.searchingTemp[index], lastIndex: index)
        }
        
        let vc = IngredientScene.editRefrigerator(vm).viewController()
        
        self.sceneCoodinator.transition(to: vc, type: .push)
        
    }
    
    func getItems(listName: List) -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
        
        //これがないとuiが更新されない
        observableItems.onNext([])
        
        _ = self.apiType.getIngredients(userID: self.user.uid, listName: .shoppinglist)
            .subscribe(onSuccess: {[unowned self]  items in
                
                if let shoppingItems = items as? [ShoppingItem] {
                   
                    self.items = shoppingItems.sorted { $0.order < $1.order }
                    
                    self.observableItems.onNext(self.items)
                    
                    relay.accept(true)
                    
                }
                
            }, onFailure: { [unowned self] err in
                err.handleFireStoreError()?.generateErrAlert()
                self.observableItems.onNext(self.items)
                relay.accept(true)
            })
        
        return relay
    }
    
    func moveItems() {
       
        _ = self.apiType.moveIngredient(userID: self.user.uid, items: self.items, listName: .shoppinglist)
            .subscribe(onNext: { isChanged in
                if isChanged {
                    print("Success!")
                }
            }, onError: { err in
                
                print("Error updating document: \(err)")
                err.handleFireStoreError()?.generateErrAlert()
                
            })
            .disposed(by: disposeBag)
    }
    
    func deleteItem(index: Int) -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
        let item = searchingTemp.isEmpty ? items[index] : searchingTemp[index]
        
        _ = self.apiType.deleteIngredient(item: item, userID: user.uid, listName: .shoppinglist)
            .subscribe(onCompleted: { [unowned self] in
                
                print("Document successfully deleted")
                
                if searchingTemp.isEmpty {
                    self.items.remove(at: index)
                    self.observableItems.onNext(self.items)
                }
                else {
                    guard let searchedIndex = self.items.firstIndex(of: self.searchingTemp[index]) else {
                        return
                    }
                    
                    self.items.remove(at: searchedIndex)
                    
                }
               
              
                relay.accept(true)
                
            }, onError: { err in
                
                print("Error updating document: \(err)")
                err.handleFireStoreError()?.generateErrAlert()
                self.observableItems.onNext(self.items)
                relay.accept(false)
            })
        
        return relay
   
    }
    
    func deleteItems() {
        
        if !deletingTemp.isEmpty {

            _ = self.apiType.deleteIngredients(items: deletingTemp, userID: user.uid, listName: .shoppinglist)
                .subscribe(onNext: { [unowned self] (isLast, ingredient) in
                    
                    print("Document successfully deleted")
                    
                    self.items.remove(at: ingredient.index)
                    
                    if isLast {
                        self.observableItems.onNext(self.items)
                    }
                    
                }, onError: { err in
                    
                    
                    print("Error updating document: \(err)")
                    
                    err.handleFireStoreError()?.generateErrAlert()
                    self.observableItems.onNext(self.items)
                })
            
            
            deletingTemp.removeAll()
            
        }
        
    }
    
    
    func cancel() -> Observable<Bool> {
        
        let publishRelay = PublishSubject<Bool>()
       
        return Observable.create { [unowned self] observer in
           
            self.observableItems
                .catch { err in

                    print(err)
                    
                    observer.onNext(false)
                    return .empty()
                }
                .subscribe(onNext: { [unowned self] items in
                
                    self.items = items
                    self.observableItems.onNext(self.items)
                    
                    publishRelay.onNext(true)
                })
                .disposed(by: self.disposeBag)
            
          
            return Disposables.create()
        }
    }
    
    func searchingItem() {
      
        searchingText.subscribe(onNext: { [unowned self] text in
            
            if text.isNotEmpty {
                
                let lowerCasedTxt = text.lowercased()
                self.searchingTemp = items.filter { $0.name.lowercased().contains(lowerCasedTxt) }
                
                self.observableItems.onNext(self.searchingTemp)
            }
            else {
                
                self.observableItems.onNext(items)
                
            }
                
        })
        .disposed(by: disposeBag)
    }
}
