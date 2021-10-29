//
//  SelectGenresVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-21.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa
import RxDataSources

protocol SelectGenreProtocol: AnyObject {
    func addGenre(genres: [Genre])
}

class SelectGenresVM: ViewModelBase {
    
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    
    let apiType: CreateRecipeDMProtocol.Type
    
    weak var delegate: SelectGenreProtocol?
    
    var text = ""
    var items = BehaviorRelay<[SectionOfGenre]>(value: [])
    var searchedItems: [SectionOfGenre] = []
    var selectedGenres = BehaviorRelay<[Genre]>(value: [])
    
    let dissapperSubject = PublishSubject<Void>()
    let searchTextSubject = PublishSubject<String>()
   
    let differenceSubject = ReplaySubject<[SectionOfGenre]>.create(bufferSize: 1)
   
    let diffenceTxtSubject = ReplaySubject<String>.create(bufferSize: 1)
    
    var isDisplayed = false
    
    
//    var shouldAddNewGenre: Observable<Bool> {
//
//        return Observable.zip(differenceSubject, differenceSubject.skip(1)) { previous, current in
//            
//            if current.count == previous.count {
//                return true
//            }
//            else if current.count == previous.count {
//                return false
//            }
//            
//            return false
//        }
//        .asObservable()
//    }
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, genres: [Genre], apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        
        super.init()
        
        let item = Genre(id: "dfjkahfajhkalhfj", title: "Hello!")
       
        var items: [Genre] = []
        
        for _ in 0 ..< 5 {
            
            items.append(item)
            
        }

        self.text = "# \(item.title)"
        

//        items.forEach { [unowned self] in
//
//            self.text += "# \($0.title)"
//
//        }
        
        let temp = SectionOfGenre(header: "temp", items: items)
        
        
        self.items.accept([temp])
        self.diffenceTxtSubject.onNext(text)
//        var items = self.selectedGenres.value
//
//        items.append(contentsOf: genres)
//
//        self.selectedGenres.accept(items)
        
        
        
        
        
    }
//
//    func getMyGenre() {
//
//        self.apiType.getMyGenresIDs(user: self.user)
//            .flatMap { self.apiType.getMyGenres(ids: $0, user: self.user) }
//            .catch { err in
//
//                print(err)
//
//                return .empty()
//
//            }
//            .subscribe(onNext: { [unowned self] genres, isLast in
//
//                if isLast {
//
//                    let sectionOfGenres = SectionOfGenre(header: "", items: genres)
//
//                    self.differenceSubject.onNext([sectionOfGenres])
//                    self.items.accept([sectionOfGenres])
//                }
//
//            })
//            .disposed(by: disposeBag)
//    }
//
//
//    func filterSearchedItems(with allItems: [SectionOfGenre], query: String) -> [SectionOfGenre] {
//
//        guard query.isNotEmpty else {
//
////            self.searchedItems.removeAll()
//
//            return allItems
//        }
//
//        return allItems.map {
//            SectionOfGenre(header: $0.header, items: $0.items.filter { $0.title.range(of: query, options: .anchored) != nil
//            })
//        }
//    }
//
//    func addGenre(indexSection: Int, indexRow: Int) {
//
//
//        let newGenre =  self.items.value[indexSection].items[indexRow]
//        var currentItems = self.selectedGenres.value
//
//        currentItems.append(newGenre)
//
//        self.selectedGenres.accept(currentItems)
//    }
//
//    func removeGenre(indexSection: Int, indexRow: Int) {
//
//        let newGenre =  self.items.value[indexSection].items[indexRow]
//        let currentItems = self.selectedGenres.value
//
//        let newItems = currentItems.filter { $0.id != newGenre.id }
//
//        self.selectedGenres.accept(newItems)
//    }
//
//    func createGenres(genres: [Genre]) -> Observable<([Genre], Bool)> {
//
//        return self.apiType.createGenres(genres: genres, user: self.user)
//
//    }
//
//    func addGenres(genres: [Genre]) {
//
//        self.sceneCoordinator.pop(animated: true)
//        self.delegate?.addGenre(genres: genres)
//
//    }
//    
//    
//    func isQueryEmpty(query: String) -> Observable<String> {
//        
//        return Observable.create { [unowned self] observer in
//            
//            if query.isEmpty  {
//               
//                self.items[1].items.remove(at: 0)
//                self.differenceSubject.onNext(self.items)
//                
//            } else {
//                
//                observer.onNext(query)
//            }
//            
//            return Disposables.create()
//        }
//    }
//    
//    func hasGenre(query: String) -> Observable<Bool> {
//        
//        return Observable.create { observer in
//            
//            if self.items[1].items.filter({ $0.title == query }).isEmpty {
//               
//                observer.onNext(false)
//            
//            }
//            else {
//                observer.onNext(true)
//            }
//            
//            return Disposables.create()
//        }
//    }
//    
//    
//    func addNewGenre(query: String) -> Observable<[SectionOfGenre]> {
//        
//        return Observable.create { [unowned self] observer in
//
//            if query.isEmpty  {
//               
//                observer.onNext(self.items)
//            
//            }
//            else {
//                
//                let uuid = UUID()
//                let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
//                
//                let newGenres = Genre(id: uniqueIdString, title: query.capitalized)
//                
//                self.items[1].items.insert(newGenres, at: 0)
//                
//                observer.onNext(self.items)
//            }
//         
//            
//            return Disposables.create()
//        }
//        
//    }
//    
//    func changeNewGenre(query: String) -> Observable<String?> {
//        
//        return Observable.create { [unowned self] observer in
//
//            if query.isEmpty  {
//               
//                self.items[1].items.remove(at: 0)
//                observer.onNext(nil)
//                
//            } else {
//                
//                self.items[1].items[0].title = query
//            }
//            
//            return Disposables.create()
//        }
//    }
//    
//    func emitsSearchTxtAndItems(query: String) -> Observable<(String, [SectionOfGenre])> {
//        
//        return Observable.zip(Observable.just(query), Observable.just(self.items))
//
//    }
//    
   
}
