//
//  RefrigeratorVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
import DifferenceKit
import Firebase
import RxSwift
import RxCocoa
import Action

enum List: String {
    case shoppinglist, refrigerator
}

class RefrigeratorVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let apiType: RefrigeratorProtocol.Type
    
    var user: FirebaseAuth.User!
    var err = NSError()
    
    let empty = RefrigeratorItem(key: "___________________empty", name: "", amount: "", index: 0)
    
    var emptyHeight: CGFloat = 140.0
    var hasEmptyCell: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    var items: [RefrigeratorItem] = []
    var searchingTemp:[RefrigeratorItem] = []
    var deletingTemp:[DeletingIngredient] = []
    
    var observableItems = PublishSubject<[RefrigeratorItem]>()
    
    var isTableViewEditable = BehaviorRelay<Bool>(value: false)
    var isSelectedCells = BehaviorRelay<Bool>(value: false)
    
    var searchingText = BehaviorRelay<String>(value: "")
    
    lazy var dataSource: RxRefrigeratorTableViewDataSource<RefrigeratorItem, RefrigeratorTVCell> = {
        
        return RxRefrigeratorTableViewDataSource<RefrigeratorItem, RefrigeratorTVCell>(identifier: RefrigeratorTVCell.identifier, emptyValue: self.empty) { section, row, element, cell in
            
            if section == 0 {
                cell.configure(item: element)
                
            }
            
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
            let vm =  EditItemRefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: nil, lastIndex: index)
            let scene: Scene = .ingredient(scene: .editRefrigerator(vm))
          
            return self.sceneCoodinator.transition(to: scene, type: .push).asObservable().map { _ in }
            
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
        
        let scene: Scene = .ingredient(scene: .editRefrigerator(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .push)
        
    }
    
    func getItems(listName: List) -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
        
        //これがないとuiが更新されない
        observableItems.onNext([])
        
        _ = self.apiType.getRefrigeratorItems(userID: self.user.uid)
            .subscribe(onSuccess: {[unowned self]  items in
                
                if let refrigeratorItems = items as? [RefrigeratorItem] {
                    
                    self.items = refrigeratorItems.sorted { $0.index < $1.index }
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
        
        _ = self.apiType.moveIngredient(userID: self.user.uid, items: self.items, listName: .refrigerator)
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
        
        _ = self.apiType.deleteIngredient(item: item, userID: user.uid, listName: .refrigerator)
            .flatMap { isDeleted in
                return self.apiType.moveIngredient(userID: self.user.uid, items: self.items, listName: .refrigerator)
            }
            .subscribe(onNext: { [unowned self] isLast in
                print("Document successfully deleted")
                
                if isLast {
                    
                    if self.searchingTemp.isEmpty {
                        
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
                }
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
            
            _ = self.apiType.deleteIngredients(items: deletingTemp, userID: user.uid, listName: .refrigerator)
                .flatMap { deletingItem in

                    return self.apiType.filterDifferentOrder(items: self.items, deletingItem: deletingItem.item)

                }
                .flatMap { [unowned self] processedItems, deletingItem in
                   
                    return self.apiType.moveIngredient(userID: user.uid, items: processedItems, deletingItem: deletingItem, listName: .shoppinglist)
                    
                }
                .subscribe(onNext: { [unowned self] isLast, deletingItem in

                    guard let index = self.items.firstIndex(where: { $0.id == deletingItem.id }) else {
                        return
                    }
                    
                    self.items.remove(at: index)
      
                    guard let isLast = isLast else {
                        return
                    }
                    
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
