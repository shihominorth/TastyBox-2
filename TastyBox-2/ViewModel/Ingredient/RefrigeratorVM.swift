//
//  RefrigeratorVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-21.
//

import Foundation
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

    var items: [RefrigeratorItem] = []
    var temp:[RefrigeratorItem] = []
    
    var observableItems = PublishSubject<[RefrigeratorItem]>()
    
    var isTableViewEditable = BehaviorRelay<Bool>(value: false)
    var isSelectedCells = BehaviorRelay<Bool>(value: false)
    
    
    var searchingText = BehaviorRelay<String>(value: "")
    
    init(sceneCoodinator: SceneCoordinator, apiType: RefrigeratorProtocol.Type = RefrigeratorDM.self, user: FirebaseAuth.User) {
        self.sceneCoodinator = sceneCoodinator
        self.apiType = apiType
        self.user = user
    }
    
    func toAddItem() -> CocoaAction {
        
        return CocoaAction { _ in
            
            let vm =  EditItemRefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: nil)
            let vc = IngredientScene.edit(vm).viewController()
            
            return self.sceneCoodinator.transition(to: vc, type: .push).asObservable().map { _ in }
        }
    }
    
    func toEditItem(index: Int)  {
        
       
            
            let vm =  EditItemRefrigeratorVM(sceneCoodinator: self.sceneCoodinator, user: self.user, item: self.items[index])
            let vc = IngredientScene.edit(vm).viewController()
            
            self.sceneCoodinator.transition(to: vc, type: .push)
        
    }
    
    func getItems(listName: List) {
       
       _ = self.apiType.getRefrigeratorDetail(userID: self.user.uid).subscribe(onSuccess: { items in
         
            self.items = items
        })
        
        _ = self.apiType.getRefrigeratorDetail(userID: self.user.uid).subscribe(onSuccess: { items in
            self.observableItems.onNext(items)
        }, onFailure: { err in
            err.handleFireStoreError()?.generateErrAlert()
        })
       
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
                self.temp = items.filter { $0.name.lowercased().contains(lowerCasedTxt) }
                
                self.observableItems.onNext(self.temp)
            }
            else {
                
                self.observableItems.onNext(items)
                
            }
                
        })
        .disposed(by: disposeBag)
    }
}
