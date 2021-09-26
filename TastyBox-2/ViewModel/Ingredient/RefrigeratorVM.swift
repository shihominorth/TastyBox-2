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

enum List {
    case shopping, refrigerator
}

class RefrigeratorVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let apiType: RefrigeratorProtocol.Type
    
    var user: FirebaseAuth.User!
    var err = NSError()
    
    let empty = RefrigeratorItem(key: "___________________empty", name: "", amount: "", order: 0)
    
    var emptyHeight: CGFloat = 140.0
    var hasEmptyCell = false
    
    var items: [RefrigeratorItem] = []
    var searchingTemp:[RefrigeratorItem] = []
    var deletingTemp:[DeletingIngredient] = []
    
    var observableItems = PublishSubject<[RefrigeratorItem]>()
    
    var isTableViewEditable = BehaviorRelay<Bool>(value: false)
    var isSelectedCells = BehaviorRelay<Bool>(value: false)
    
    var searchingText = BehaviorRelay<String>(value: "")
    
    lazy var dataSource: RxRefrigeratorTableViewDataSource<RefrigeratorItem, IngredientTableViewCell> = {
        
        return RxRefrigeratorTableViewDataSource<RefrigeratorItem, IngredientTableViewCell>(identifier: IngredientTableViewCell.identifier, emptyValue: self.empty) { row, element, cell in
            
            cell.configure(item: element)
            
        }
    }()
    
    init(sceneCoodinator: SceneCoordinator, apiType: RefrigeratorProtocol.Type = RefrigeratorDM.self, user: FirebaseAuth.User) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.user = user
        
//        for i in 16... {
//            
//            Firestore.firestore().collection("users").document(user.uid).collection("refrigerator").document().setData([
//                
//                "name": "name",
//                "amount": "amount",
//                "order": i
//                
//            ], merge: true) { err in
//                if let err = err {
//                    
//                    print(err)
//                    
//                }
//                
//            }
//        }
    }
    
    func toAddItem() -> CocoaAction {
        
        return CocoaAction { _ in
            
            let index = self.items.count
            let vm =  EditItemRefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: nil, lastIndex: index)
            let vc = IngredientScene.edit(vm).viewController()
            
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
        
        let vc = IngredientScene.edit(vm).viewController()
        
        self.sceneCoodinator.transition(to: vc, type: .push)
        
    }
    
    func getItems(listName: List) -> PublishRelay<Bool> {
        
        let relay = PublishRelay<Bool>()
        
        //これがないとuiが更新されない
        observableItems.onNext([])
        
        _ = self.apiType.getIngredients(userID: self.user.uid)
            .subscribe(onSuccess: {[unowned self]  items in
                
                self.items = items.sorted { $0.order < $1.order }
                
                self.observableItems.onNext(self.items)
                
                relay.accept(true)
                
                
            }, onFailure: { [unowned self] err in
                err.handleFireStoreError()?.generateErrAlert()
                self.observableItems.onNext(self.items)
                relay.accept(true)
            })
        
        return relay
    }
    
    func moveItems() {
       
        _ = self.apiType.moveIngredient(userID: self.user.uid, items: self.items)
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
        
        _ = self.apiType.deleteIngredient(item: item, userID: user.uid)
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

            _ = self.apiType.deleteIngredients(items: deletingTemp, userID: user.uid)
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
