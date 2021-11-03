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
    var selectedArrGenres = ReplaySubject<[String]>.create(bufferSize: 1)
    var items = BehaviorRelay<[SectionOfGenre]>(value: [])
    //    var searchedItems: [SectionOfGenre] = []
    var searchedItems:[Genre] = []
    var selectedGenres = BehaviorRelay<[Genre]>(value: [])
    
    let dissapperSubject = PublishSubject<Void>()
    let searchTextSubject = PublishSubject<String>()
    
    let differenceSubject = ReplaySubject<[SectionOfGenre]>.create(bufferSize: 1)
    
    let diffenceTxtSubject = ReplaySubject<String>.create(bufferSize: 1)
    
    var isDisplayed = false
    var isEditingSubject = BehaviorRelay<Bool>(value: false)
    
    var selectedGenreSubject = BehaviorRelay<Genre?>(value: nil)
    
    var isNewTagInputs: Observable<Bool> {
        
        return Observable.zip(diffenceTxtSubject, diffenceTxtSubject.skip(1)) { previous, current in
            
            let isNewHashTagInputs = current.filter { $0 != " " } .filter { char in
                
                !previous.contains(where: { $0 == char })
                
            }.map { char in
                
                //                print(char)
                
                return String(char)
                
            }.contains(where: { $0 == "#" })
            
            return isNewHashTagInputs
        }
    }
    
    var searchingQuery: Observable<String> {
        
        return Observable.zip(diffenceTxtSubject, diffenceTxtSubject.skip(1)) { previous, current in
            
            var previousNoHashTagArr = previous.components(separatedBy: "#").filter { $0 != "" }
            previousNoHashTagArr = previousNoHashTagArr.map { $0.filter { char in
                
                return char != " "
                
            } }
            
            var currentNoHashTagArr = current.components(separatedBy: "#").filter { $0 != "" }
            currentNoHashTagArr = currentNoHashTagArr.map { $0.filter { char in
                
                return char != " "
                
            } }
            
            let compareArr = zip(previousNoHashTagArr, currentNoHashTagArr)
            
            if currentNoHashTagArr.count - 1 == previousNoHashTagArr.count {
                
                if let item = currentNoHashTagArr.first(where: { !previousNoHashTagArr.contains($0) }) {
                    return item
                }
            }
            
            if let query = compareArr.first(where: { $0.0 != $0.1 })?.1 {
                
                return query
            }
            
            return ""
        }
        
    }
    
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
    
    //MARK: Genre should capitlized when searching and registering
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User, genres: [Genre], apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        self.apiType = apiType
        
        super.init()
        
        //        let item = Genre(id: "dfjkahfajhkalhfj", title: "Hello!")
        //
        //        var items: [Genre] = []
        //
        //        for _ in 0 ..< 5 {
        //
        //            items.append(item)
        //
        //        }
        //
        //        self.text = "# \(item.title)"
        
        
        genres.forEach { [unowned self] in
            
            self.text += "# \($0.title) "
            
        }
        
//        selectedGenres.accept(genres)
        
//        let temp = SectionOfGenre(header: "temp", items: [])
        //
        //
        
//        self.items.accept([temp])
        
        
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
//                    genres.forEach {
//
//                        print($0.id)
//                        print($0.title)
//
//                    }
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
    
    func getMyGenre() -> Observable<[Genre]> {
  
        return self.apiType.getMyGenresIDs(user: self.user)
            .flatMap { self.apiType.getMyGenres(ids: $0, user: self.user) }
            .catch { err in

                print(err)

                return .empty()

            }
            .filter { $0.1 == true }
            .map { $0.0 }
//            .do(onNext: {
                
//                $0.forEach {
//                    
//                    print($0.id)
//                    print($0.title)
//                    
//                }
//               //
//                let sectionOfGenres = SectionOfGenre(header: "", items: $0)
//               //
//                self.differenceSubject.onNext([sectionOfGenres])
//                self.items.accept([sectionOfGenres])
//            })
 
      }
    
    
    func searchGenres(query: String) -> Observable<[Genre]> {
        
        return self.apiType.searchGenres(searchWord: query)
        
    }
    
    
    func selectGenre(genres: [Genre], query: String) {
        
        guard let genre = genres.first(where: { $0.title == query }) else { return }
        var newItems = selectedGenres.value
        
        newItems.append(genre)
        
        
        selectedGenres.accept(newItems)
        
        
    }
    
    func filterSearchedGenres() -> Observable<([Genre], [String])> {
        
        
        return Observable.combineLatest(diffenceTxtSubject, selectedGenres)
            .flatMapLatest { [unowned self] txt, selectedGenres in
                self.apiType.filterNotSearchedGenres(genres: selectedGenres, txt: txt)
            }
            .catch { err in
                
                print(err)
                
                return .empty()
            }
        
    }
    
    
    
    func searchIsFirebaseKnowsGenre(txts: [String], alreadyKnowsGenres: [Genre]) -> Observable<([Genre], [String])> {
        
        return Observable.create { observer in
            
            
            var existGenres: [Genre] = []
            var notExistGenres:[String] = []
            
            if txts.isEmpty {
                observer.onNext((alreadyKnowsGenres, []))
            }
            else  {
                
                txts.enumerated().forEach { index, txt in
                    
                    self.apiType.isFirebaseKnowsGenres(word: txt, completion: { genre in
                        
                        if let genre = genre {
                            
                            existGenres.append(genre)
                            
                        }
                        else {
                            notExistGenres.append(txt)
                        }
                        
                        if existGenres.count + notExistGenres.count == txts.count {
                            existGenres.append(contentsOf: alreadyKnowsGenres)
                            observer.onNext((existGenres, notExistGenres))
                        }
                        
                    }, errBlock: { err in
                        
                        print(err)
                        
                        notExistGenres.append(txt)
                        
                        if existGenres.count + notExistGenres.count == txts.count {
                            existGenres.append(contentsOf: alreadyKnowsGenres)
                            observer.onNext((existGenres, notExistGenres))
                        }
                        
                    })
                }
                
            }
            
            return Disposables.create()
        }
        
        
    }
    
    func registerGenres(words: [String], genres: [Genre]) -> Observable<[Genre]> {
        
        return Observable.combineLatest(registerNewGenres(words: words).map { $0 }.startWith([]), registerAsMyGenres(genres: genres).map { $0 }.startWith([])) { registeredNewGenres, registeredMyGenres in
            
            var result = registeredNewGenres
            result.append(contentsOf: registeredMyGenres)
            
            return result
        }
        .skip(1)
        .flatMapLatest{ [unowned self] genres in
            self.shouldAddGenres(genres: genres)
        }
        .catch { err in
            
            print(err)
            
            return .empty()
        }
        
    }
    
    func registerNewGenres(words: [String]) -> Observable<[Genre]> {
        
        return self.apiType.registerNewGenres(genres: words, user: self.user)
        
    }
    
    func registerAsMyGenres(genres: [Genre]) -> Observable<[Genre]> {
        
        return self.apiType.isUserInterested(genres: genres, user: self.user)
    }
    
    func shouldAddGenres(genres: [Genre]) -> Observable<[Genre]> {
        
        return diffenceTxtSubject
            .filter { txt in
                
                var arr = txt.components(separatedBy: "#").filter { $0 != "" }
                arr = arr.map { $0.filter { char in
                    
                    return char != " "
                    
                } }
                
                return arr.count == genres.count
            }
            .flatMapLatest { _ in
                return Observable.just(genres)
            }
        
        
    }
    
  
    
    func addGenres(genres:[Genre]) -> Observable<[Genre]> {
        
        return diffenceTxtSubject.flatMap { txt in
            
            self.sortedGenres(txt: txt, genres: genres)
            
        }
        .catch { err in
            
            print(err)
            
            return .empty()
        }
        
    }
    
    func sortedGenres(txt: String, genres: [Genre]) -> Observable<[Genre]> {
        
        return Observable.create { observer in
            
            let arr: [String] = txt.components(separatedBy: "#")
                .filter { $0 != "" }
                .map { $0.filter { char in
                    
                    return char != " "
                    
                }}
            
            var sortedArr: [Genre] = []
            let flatteddMapArr: [Genre] = genres.compactMap { $0 }
            
            arr.forEach { txt in
                
                if let genre = flatteddMapArr.first(where: { $0.title == txt} ) {
                    
                    sortedArr.append(genre)
                    
                }
            }
            
            sortedArr = sortedArr.filter { $0.title != "" }
            
            observer.onNext(sortedArr)
            
            return Disposables.create()
        }
    }
    
    func dismissSelection() {
        
        self.sceneCoordinator.userDissmissed()
        
    }
    
    func convertNewTxt(txt: String, query: String, selectedGenre: Genre?) -> Observable<String> {
        
        
        return .create { observer in
            
            var arr = txt.components(separatedBy: "#").filter { $0 != "" }
            //
            arr = arr.map { $0.filter { char in
                
                return char != " "
                
            } }
            
            
            
            if let title = selectedGenre?.title, let removeIndex = arr.firstIndex(where: { $0 == query }) {
                
                arr.insert(title, at: removeIndex)
                arr.remove(at: removeIndex + 1)
                
                var newString = arr.joined(separator: " # ")
                newString.insert("#", at: newString.startIndex)
                newString.insert(" ", at: newString.index(after: newString.startIndex))
                
                
                observer.onNext(newString)
                
            }
            
            
            
            return Disposables.create()
        }
        
    }
    
}
