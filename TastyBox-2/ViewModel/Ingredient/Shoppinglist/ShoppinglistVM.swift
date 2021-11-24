//
//  ShoppinglistVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-26.
//

import Foundation
import Action
import Firebase
import FirebaseFirestore
import RxCocoa
import RxSwift
import RxTimelane

class ShoppinglistVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let apiType: RefrigeratorProtocol.Type
    
    var user: FirebaseAuth.User!
    var err = NSError()
    
    let empty = ShoppingItem(name: "___________________empty", amount: "", key: "", isBought: false, index: 0)
    
    var emptyHeight: CGFloat = 140.0
    var hasEmptyCell: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    var docs: [QueryDocumentSnapshot] = []
    var items: [ShoppingItem] = []
    var searchingTemp:[ShoppingItem] = []
    var deletingTemp:[DeletingIngredient] = []
    
    var observableItems = BehaviorRelay<[ShoppingItem]>(value: [])
    
    var isTableViewEditable = BehaviorRelay<Bool>(value: false)
    var isSelectedCells = BehaviorRelay<Bool>(value: false)
    
    let noDifferentBoughtStatusItemsSubject = PublishSubject<Bool>()
    
    let isBoughtItemsSubject = PublishSubject<Bool>()
    let isNotBoughtItemsSubject = PublishSubject<Bool>()
    
    let isShownBoughtItemsRelay = BehaviorRelay<Bool>(value: false)
    
    
    lazy var dataSource: RxRefrigeratorTableViewDataSource<ShoppingItem, ShoppinglistTVCell> = {
        
        return RxRefrigeratorTableViewDataSource<ShoppingItem, ShoppinglistTVCell>(identifier: ShoppinglistTVCell.identifier, emptyValue: self.empty) { [unowned self] section, row, element, cell in
            
            if section == 0 {
                cell.configure(item: element)
            }

            cell.checkMarkBtn.rx.tap
                .lane("before debounce")
                .debounce(.microseconds(1500), scheduler: MainScheduler.instance)
                .single()
                .catch { err in

                    return Observable.never()

                }
                .lane("after debounce")
                .do(onNext: {_ in
                    print(element.name)
                })
                .flatMap {
                    // rowがおかしい
//                    updateBoughtStatus(index: row)
                    updateBoughtStatus(item: element)
                }
                .lane("cold")
                .subscribe(onNext: { [unowned self] isBought in
                   
                    cell.updateCheckMark(isBought: isBought)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                        if !isShownBoughtItemsRelay.value  {
                            self.observableItems.accept(self.items)
                        }
  
                    }
                    
                }, onError: { err in
                    print(err)
                })
                .disposed(by: cell.bag)
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
            
            vm.delegate = self
            
            return self.sceneCoodinator.transition(to: vc, type: .push).asObservable().map { _ in }
        }
    }
    
    func toEditItem(index: Int)  {

        var editItem: ShoppingItem {
            
            if !isShownBoughtItemsRelay.value {
                
                let filteredAllitems = items.filter { !$0.isBought }
                let filteredSearchingTemp = searchingTemp.filter { !$0.isBought }
                
                return searchingTemp.isEmpty ? filteredAllitems[index] : filteredSearchingTemp[index]
                
            }
           
            return searchingTemp.isEmpty ? items[index] : searchingTemp[index]
            
        }
        
        
        let vm = EditShoppinglistVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: editItem, lastIndex: index)
        
        
        let vc = IngredientScene.editShoppinglist(vm).viewController()

        vm.delegate = self

        
        self.sceneCoodinator.transition(to: vc, type: .push)
        
    }
    
    func getItems() -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
        
        //これがないとuiが更新されない
        observableItems.accept([])
        
        _ = self.apiType.getShoppinglist(userID: self.user.uid)
            .subscribe(onSuccess: {[unowned self] items, docs in
                
                self.items = items
                self.docs = docs
                
                self.observableItems.accept(self.items)
                
                relay.accept(true)
                
            }, onFailure: { [unowned self] err in
                
                err.handleFireStoreError()?.generateErrAlert()
                
                self.observableItems.accept(self.items)
                
                relay.accept(true)
            })
        
        
        
        return relay
    }
    
    
    func showsBoughtItems() -> Observable<Bool> {

        return Observable.create { [unowned self] observer in
            
            let newValue = !self.isShownBoughtItemsRelay.value
            self.isShownBoughtItemsRelay.accept(newValue)
            
            observer.onNext(newValue)
            
            return Disposables.create()
        }
                
    }
    

    
    
    func moveItems(sourceIndex: Int, destinationIndex: Int) {
    
        if searchingTemp.isEmpty {
            
             let movingItem = self.items[sourceIndex]

             self.items.remove(at: sourceIndex)
             self.items.insert(movingItem, at: destinationIndex)

        }
        else {
            
            let movingSourceIndexItem = self.searchingTemp[sourceIndex]
            guard let movingSourceIndex = self.items.firstIndex(where:{ movingSourceIndexItem.id == $0.id } ) else {
                return
            }
            
            let movingDestinationIndexItem = self.searchingTemp[destinationIndex]
            guard let movingDestinationIndex = self.items.firstIndex(where:{ movingDestinationIndexItem.id == $0.id } ) else {
                return
            }
            
            self.items.swapAt(movingSourceIndex, movingDestinationIndex)
        }
       
    }
    
    fileprivate func moveItemsAfterDeleteItem() {
        
        self.apiType.moveIngredient(userID: self.user.uid, items: self.items, listName: .shoppinglist)
            .subscribe(onNext: { isLastMoved in
                
                if isLastMoved {
                    print("all done!")
                }
                
            }, onError: { err in
                
                print(err)
                
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func editShoppinglist() {

        let filteredDifferentBoughtStatusItems =
            self.apiType.filterDifferencntBoughtStatus(docs: self.docs, processedItems: self.items)
            .flatMap {
                self.isEmptyShoppingItems(items: $0)
            }

        let isBoughtItemsStream = filteredDifferentBoughtStatusItems
            .flatMap { [unowned self] in self.filterIsBought(isBought: true, items: $0) }
            .do(onNext: { [unowned self] items in
                
                if items.isEmpty {
                    self.isBoughtItemsSubject.onNext(items.isEmpty)
                }
                
            })
            .flatMap { [unowned self] in self.apiType.isBoughtShoppinglistItems(processedItems: $0, userID: self.user.uid)}
            .flatMap { [unowned self] isLast, item -> Observable<(Int, ShoppingItem, Bool)> in

                let getDocsCount = self.apiType.getRefrigeratorDocsCount(userID: self.user.uid)
                    .catch { err in
                        print(err)
                        return .empty()
                    }

                let observeItem = Observable.just(item)

                let observeIsLast = Observable.just(isLast)

                return Observable.combineLatest(getDocsCount, observeItem, observeIsLast)
            }
            .flatMap { [unowned self] count, item, isLast -> Observable<Bool> in

                return  self.addRefrigeratorItem(item: item, isLast: isLast, count: count)

            }
           

        
        let isNotBoughtItemsStream = filteredDifferentBoughtStatusItems
            .flatMap { [unowned self] in self.filterIsBought(isBought: false, items: $0)}
            .do(onNext: { [unowned self] items in
                
                if items.isEmpty {
                    self.isNotBoughtItemsSubject.onNext(items.isEmpty)
                }
                
            })
            .flatMap { [unowned self] in self.apiType.isBoughtShoppinglistItems(processedItems: $0, userID: self.user.uid) }
            .flatMap { [unowned self] isLast, item -> Observable<Bool> in

                return self.deleteRefrigeratorItem(item: item, isLast: isLast)

            }

        
        noDifferentBoughtStatusItemsSubject.subscribe(onNext: { [unowned self] isEmpty in
            
            if isEmpty {
                self.moveItemsAfterDeleteItem()
            }
            
        }, onError: { err in
            
            print(err)
            
        })
        .disposed(by: disposeBag)
    
        Observable.combineLatest(isBoughtItemsStream, isNotBoughtItemsStream)
            .subscribe(onNext: { [unowned self] isLastBoughtItems, isLastNotBoughtItems in

                self.isBoughtItemsSubject.onNext(isLastBoughtItems)
                self.isNotBoughtItemsSubject.onNext(isLastNotBoughtItems)

            }, onError: { err in

                print(err)

            })
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(isBoughtItemsSubject, isNotBoughtItemsSubject)
            .debug("subject")
            .asDriver(onErrorJustReturn: (true, true))
            .drive { [unowned self] isLastBoughtItems, isLastNotBoughtItems in
               
                if isLastBoughtItems && isLastNotBoughtItems {
                    self.moveItemsAfterDeleteItem()
                }
            }
            .disposed(by: disposeBag)
           
          
        
        
    }
    
//    func updateBoughtStatus(index: Int) -> Observable<Bool> {
    func updateBoughtStatus(item: ShoppingItem) -> Observable<Bool> {
        
        return Observable.create { [unowned self] observer in
            
//            self.observableItems.value[index].isBought = !self.observableItems.value[index].isBought
            if isShownBoughtItemsRelay.value {
                    
                
//                let item = searchingTemp.isEmpty ? items[index] : searchingTemp[index]
                
                    
                if  let indexAllItems = self.items.firstIndex(where: { $0.id == item.id }) {
                        
                    self.items[indexAllItems].isBought = !self.items[indexAllItems].isBought
                    observer.onNext(self.items[indexAllItems].isBought)

                }
              
            }
            else {
               
                if searchingTemp.isEmpty {
                    
                    let filteredAllitems = items.filter { !$0.isBought }
                    
//                    let item = filteredAllitems[index]
                    
                    if let indexAllItems = self.items.firstIndex(where: { $0.id == item.id }) {
                       
                        self.items[indexAllItems].isBought = !self.items[indexAllItems].isBought
                        observer.onNext(self.items[indexAllItems].isBought)

                    }
                    
                }
                else {
                    
                    let filteredSearchingTemp = searchingTemp.filter { !$0.isBought }
//                    let item = filteredSearchingTemp[index]
                    
                    if let indexAllItems = self.items.firstIndex(where: { $0.id == item.id }) {
                       
                        self.items[indexAllItems].isBought = !self.items[indexAllItems].isBought
                        
                        observer.onNext(self.items[indexAllItems].isBought)
                    }
                 
                }
            }
           
          
            
            
//            observer.onNext(self.observableItems.value[index].isBought)
            
            return Disposables.create()
        }
    }
    
    
    func deleteItem(index: Int) -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
//        let deleteItem = searchingTemp.isEmpty ? items[index] : searchingTemp[index]
        
        var deleteItem: ShoppingItem {
            
            if isShownBoughtItemsRelay.value {
                
                let filteredAllitems = items.filter { !$0.isBought }
                let filteredSearchingTemp = items.filter { !$0.isBought }
                
                return searchingTemp.isEmpty ? filteredAllitems[index] : filteredSearchingTemp[index]
                
            }
           
            return searchingTemp.isEmpty ? items[index] : searchingTemp[index]
            
        }
        
        _ = self.apiType.deleteIngredient(item: deleteItem, userID: user.uid, listName: .shoppinglist)
            .flatMap { deletingItem in
                
                return self.apiType.filterDifferentOrder(items: self.items, deletingItem: deletingItem)
                
            }
            .flatMap { [unowned self] processedItems, deletingItem in
                
                return self.apiType.moveIngredient(userID: user.uid, items: processedItems, deletingItem: deletingItem, listName: .shoppinglist)
                
            }
            .subscribe(onNext: { [unowned self] isLast, deletingItem in
                
                print("Document successfully deleted")
                
                self.items = self.items.filter { $0.id != deletingItem.id }.sorted { $0.index < $1.index }
                
                if let isLast = isLast {
                    
                    if isLast {
                        self.observableItems.accept(self.items)
                    }
                }
                else {
                    self.observableItems.accept(self.items)
                }
                
                relay.accept(true)
                
            }, onError: { err in
                
                print("Error updating document: \(err)")
                err.handleFireStoreError()?.generateErrAlert()
                self.observableItems.accept(self.items)
                relay.accept(false)
                
            })
        
        
        return relay
        
    }
    
    func deleteItems() {
        
        
        if !deletingTemp.isEmpty {
            
            _ = self.apiType.deleteIngredients(items: deletingTemp, userID: user.uid, listName: .shoppinglist)
                .flatMap { deletingItem in
                    
                    return self.apiType.filterDifferentOrder(items: self.items, deletingItem: deletingItem.item)
                    
                }
                .flatMap { [unowned self] processedItems, deletingItem in
                    
                    return self.apiType.moveIngredient(userID: user.uid, items: processedItems, deletingItem: deletingItem, listName: .shoppinglist)
                    
                }
                .subscribe(onNext: { [unowned self] isLast, deletingItem in
                    
                    print("deleting item is \(deletingItem.name)")
                    
                    self.items = self.items.filter { $0.id != deletingItem.id } 
                    
                    if let isLast = isLast {
                        
                        if isLast {
                            self.observableItems.accept(self.items)
                        }
                    }
                    else {
                        self.observableItems.accept(self.items)
                    }
                    
                    
                }, onError: { err in
                    
                    print("Error updating document: \(err)")
                    
                    err.handleFireStoreError()?.generateErrAlert()
                    self.observableItems.accept(self.items)
                }, onCompleted: { 
                    print("completed")
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
                    self.observableItems.accept(self.items)
                    
                    publishRelay.onNext(true)
                })
                .disposed(by: self.disposeBag)
            
            
            return Disposables.create()
        }
    }
    
    
    func filterSearchedItems(with allItems: [ShoppingItem], isShownBoughtItems isShown: Bool, query: String) -> [ShoppingItem] {
        
        
        if isShown {
            
            guard query.isNotEmpty else {
                self.searchingTemp.removeAll()
                return allItems
            }
            
            let lowerCasedTxt = query.lowercased()
            self.searchingTemp = items.filter { $0.name.lowercased().contains(lowerCasedTxt) }
            
            return self.searchingTemp
        }
        else {
            guard query.isNotEmpty else {
                self.searchingTemp.removeAll()
                return allItems.filter { !$0.isBought }
            }
            
            let lowerCasedTxt = query.lowercased()
           
            self.searchingTemp =
                items.filter { $0.name.lowercased().contains(lowerCasedTxt) }
                .filter { !$0.isBought }
            
            return self.searchingTemp
        }
        
    }
    
    func filterIsBought(isBought: Bool, items: [ShoppingItem]) -> Observable<[ShoppingItem]> {
        
        return Observable.create { observer in
            
            let result = items.filter { $0.isBought == isBought }
            
            observer.onNext(result)
            
            return Disposables.create()
        }
    }
    
    func isEmptyShoppingItems(items: [ShoppingItem]) -> Observable<[ShoppingItem]> {
        
        return Observable.create { [unowned self] observer in
            
            if items.isEmpty {
                
                self.noDifferentBoughtStatusItemsSubject.onNext(true)
                self.isBoughtItemsSubject.onCompleted()
                self.isNotBoughtItemsSubject.onCompleted()
                
            }
            else {
                
                self.noDifferentBoughtStatusItemsSubject.onCompleted()
                
                observer.onNext(items)
            }
            
            return Disposables.create()
            
        }
        
    }
    
    func emitSingleElement(items: [ShoppingItem]) -> Observable<(ShoppingItem, Bool)> {
        
        return Observable.create { observer in
            
            items.enumerated().forEach { index, item in
                
                if index == items.count - 1 {
                    observer.onNext((item, true))
                }
                else {
                    observer.onNext((item, false))
                }
               
            }
            
            return Disposables.create()
        }
    }
    
    
    func addRefrigeratorItem(item: ShoppingItem, isLast: Bool, count: Int) -> Observable<Bool> {
        
        return Observable.create { [unowned self] observer in
            
            //        self.apiType.askHasIngredient(name: name)はアイテム追加時に呼んであるので、idはdbが知っているのと一緒
            // よって　上記のfunctionは呼ばなくていい
            self.apiType.addIngredient(id: item.id, name: item.name, amount: item.amount, userID: self.user.uid, lastIndex: count, listName: .refrigerator)
                .subscribe(onNext: { addedItem in
                    
                    print("add \(addedItem.id) to refrigerator")
                    
                    
                }, onError: { err in
                    
                    print(err)
                    
                })
                .disposed(by: self.disposeBag)
            
            observer.onNext(isLast)
            
            return Disposables.create()
            
        }
    }
    
    
    func deleteRefrigeratorItem(item: ShoppingItem, isLast: Bool) -> Observable<Bool> {
       
        return Observable.create { [unowned self] observer in
           
            self.apiType.deleteIngredient(item: item, userID: self.user.uid, listName: .refrigerator)
                .subscribe(onNext: { deletedItem in
                    
                    print("id: \(deletedItem.id), name: \(deletedItem.name) is deleted.")
                   
                    
                }, onError: { err in
                    
                    print(err)
                    
                })
                .disposed(by: self.disposeBag)

            observer.onNext(isLast)
            
            return Disposables.create()
        }
    }
}


extension ShoppinglistVM: EditShoppingItemDelegate {
    
    func addItemToArray(item: ShoppingItem){
    
        self.items.append(item)
        self.observableItems.accept(self.items)
            
    }
    
   
    func edittedItem(item: ShoppingItem) {

        guard let firstIndex = self.items.firstIndex(where: { $0.id == item.id }) else { return }
        
        self.items.remove(at: firstIndex)
        self.items.insert(item, at: firstIndex)
        
        self.observableItems.accept(self.items)
    }
    
    
}
