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
    
    var docs: [QueryDocumentSnapshot] = []
    var items: [ShoppingItem] = []
    var searchingTemp:[ShoppingItem] = []
    var deletingTemp:[DeletingIngredient] = []
    
    var observableItems = BehaviorRelay<[ShoppingItem]>(value: [])
    
    var isTableViewEditable = BehaviorRelay<Bool>(value: false)
    var isSelectedCells = BehaviorRelay<Bool>(value: false)
    
    var searchingText = BehaviorRelay<String>(value: "")
    
    //    lazy var dataSource: RxRefrigeratorTableViewDataSource<ShoppingItem, ShoppinglistTVCell> = {
    //
    //        return RxRefrigeratorTableViewDataSource<ShoppingItem, ShoppinglistTVCell>(identifier: ShoppinglistTVCell.identifier, emptyValue: self.empty) { [unowned self] row, element, cell in
    //
    //            cell.configure(item: element)
    //
    //            cell.checkMarkBtn.rx.tap
    //                .catch { err in
    //                    print(err)
    //                    return .empty()
    //                }
    //                .subscribe(onNext: {
    //
    //                    element.isBought = !element.isBought
    //                    self.items[row].isBought = !self.items[row].isBought
    //                    cell.updateCheckMark(isBought: self.items[row].isBought)
    //
    //                }, onError: { err in
    //                    print(err)
    //                })
    //                .disposed(by: self.disposeBag)
    //        }
    //    }()
    
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
    
    func getItems() -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
        
        //これがないとuiが更新されない
        observableItems.accept([])
        
        _ = self.apiType.getShoppinglist(userID: self.user.uid)
            .subscribe(onSuccess: {[unowned self] items, docs in
                
                //                self.originalItems = originalItems.sorted { $0.order < $1.order }
                //
                //                self.items = items.sorted { $0.order < $1.order }
                
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
    
    
    fileprivate func moveItems() {
        
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
        
        self.apiType
            .filterDifferencntBoughtStatus(docs: self.docs, processedItems: self.items)
            .subscribe(onNext: { items in
                
                if items.isEmpty {
                    self.moveItems()
                }
                else {
                    
                    self.apiType.isBoughtShoppinglistItems(processedItems: items, userID: self.user.uid)
                        .subscribe(onNext: { isLast, item in
                            
                            if item.isBought {
                                
                                self.apiType.getRefrigeratorDocsCount(userID: self.user.uid)
                                    .subscribe(onNext: { count in
                                        
                                        self.apiType.addIngredient(id: item.id, name: item.name, amount: item.amount, userID: self.user.uid, lastIndex: count, listName: .refrigerator)
                                            .debug()
                                            .subscribe(onCompleted: {
                                                
                                                if isLast {
                                                    self.moveItems()
                                                }
                                                
                                            }, onError: { err in
                                                print(err)
                                            })
                                            .disposed(by: self.disposeBag)
                                        
                                    }, onError: { err in
                                        print(err)
                                    })
                                    .disposed(by: self.disposeBag)
                                
                            }
                            else {
                                
                                self.apiType.deleteIngredient(item: item, userID: self.user.uid, listName: .refrigerator)
                                    .debug()
                                    .subscribe(onError: { err in
                                        print(err)
                                    }, onCompleted: {
                                        
                                        if isLast {
                                            
                                            self.moveItems()
                                            
                                        }
                                        
                                    })
                                    .disposed(by: self.disposeBag)
                            }
                        }, onError: { err in
                            print(err)
                        })
                        .disposed(by: self.disposeBag)
                    
                }
                
                
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func updateBoughtStatus(index: Int) -> Observable<Bool> {
        
        return Observable.create { [unowned self] observer in
            
            self.observableItems.value[index].isBought = !self.observableItems.value[index].isBought
            
            observer.onNext(self.observableItems.value[index].isBought)
            
            return Disposables.create()
        }
    }
    
    
    func deleteItem(index: Int) -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
        let deleteItem = searchingTemp.isEmpty ? items[index] : searchingTemp[index]
        
        _ = self.apiType.deleteIngredient(item: deleteItem, userID: user.uid, listName: .shoppinglist)
            .flatMap { deletingItem in

                return self.apiType.filterDifferentOrder(items: self.items, deletingItem: deletingItem)

            }
            .flatMap { [unowned self] processedItems, deletingItem in
                
                return self.apiType.moveIngredient(userID: user.uid, items: processedItems, deletingItem: deletingItem, listName: .shoppinglist)
                
            }
            .subscribe(onNext: { [unowned self] isLast, deletingItem in
                
                print("Document successfully deleted")
                
                self.items = self.items.filter { $0.id != deletingItem.id }
                
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
    
    func searchingItem() {
        
        searchingText.subscribe(onNext: { [unowned self] text in
            
            if text.isNotEmpty {
                
                let lowerCasedTxt = text.lowercased()
                self.searchingTemp = items.filter { $0.name.lowercased().contains(lowerCasedTxt) }
                
                self.observableItems.accept(self.searchingTemp)
            }
            else {
                
                self.observableItems.accept(items)
                
            }
            
        })
        .disposed(by: disposeBag)
    }
}
