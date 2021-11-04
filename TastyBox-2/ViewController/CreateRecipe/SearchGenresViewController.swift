//
//  SearchGenresViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-29.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class SearchGenresViewController: UIViewController, BindableType {
 
    typealias ViewModelType = SelectGenresVM
    var viewModel: SelectGenresVM!
    
   
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
        
    var dataSource: RxCollectionViewSectionedReloadDataSource<SectionOfGenre>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewModel.sceneCoordinator.userDissmissed()
    }
    
    func bindViewModel() {

        setUpcollectionView()
        
        viewModel.getMyGenre()
            .subscribe(onNext: { [unowned self] in
                
                self.viewModel.diffenceTxtSubject.onNext("")
                self.viewModel.diffenceTxtSubject.onNext("")

                
                let sectionOfGenres = SectionOfGenre(header: "", items: $0)
            
                self.viewModel.items.accept([sectionOfGenres])
                
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
//
//                if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SearchedGenresTVCell {
//
//                    cell.layoutIfNeeded()
//                    cell.collectionView.reloadData()
//
//                }
            })
            .disposed(by: viewModel.disposeBag)
      
        viewModel.searchingQuery
            .filter { query in

                if query.isEmpty {
                    
                    let temp = SectionOfGenre(header: "temp", items: [])
                    self.viewModel.items.accept([temp])
                }
                
                return !query.isEmpty
                
            }
            .flatMapLatest { [unowned self] in
                self.viewModel.searchGenres(query: $0)
            }
            .subscribe(onNext: { [unowned self] genres in
                
                if genres.isEmpty {

                    let section = SectionOfGenre(header: "temp", items: [])
                    self.viewModel.items.accept([section])
                    
                }
                else {

                    let oldItems = self.viewModel.items.value[0].items

                    if oldItems.isEmpty {
                        
                        let section = SectionOfGenre(header: "temp", items: genres)
                        self.viewModel.items.accept([section])
                        
                    }
                    else {

                        let isSameArr = oldItems.allSatisfy { item in
                            genres.contains { $0.title == item.title }
                        }
                        
                        if !isSameArr {
                            
                            let section = SectionOfGenre(header: "temp", items: genres)
                            self.viewModel.items.accept([section])
                            
                        }
                    }
                }
               
              
                
                
            })
            .disposed(by: viewModel.disposeBag)
        
        var searchingQuery = ""
        
        viewModel.isNewTagInputs
            .filter { $0 }
            .withLatestFrom(viewModel.searchingQuery)
            .do(onNext: { text in
                
                searchingQuery = text
                
            })
            .flatMapLatest { [unowned self] in
                self.viewModel.searchGenres(query: $0)
            }
            .subscribe(onNext: { [unowned self] genres in
                
                self.viewModel.selectGenre(genres: genres, query: searchingQuery)
                
            })
            .disposed(by: viewModel.disposeBag)
        
       
        // addbtn tapped then change text in text view cause the bug that addBtn.rx.tap emit event.
        // doesn't go inside any function under addBtn.rx.tap
        
        
        addBtn.rx.tap
            .debug()
            .flatMapLatest { [unowned self] in
                self.viewModel.filterSearchedGenres()
            }
            .flatMapLatest { genres, notSearchedWords in
                
                self.viewModel.searchIsFirebaseKnowsGenre(txts: notSearchedWords, alreadyKnowsGenres: genres)
                
            }
            .flatMapLatest { genres, notSearchedWords in
            
                self.viewModel.registerGenres(words: notSearchedWords, genres: genres)
            
            }
            .flatMapLatest({ [unowned self] genres in
                self.viewModel.addGenres(genres: genres)
            })
            .subscribe (onNext: {  [unowned self] genres in

                self.dismiss(animated: true) {
                    
                    self.viewModel.delegate?.addGenre(genres: genres)

                }

            })
            .disposed(by: viewModel.disposeBag)
        
        cancelBtn.rx.tap
            .subscribe(onNext: {[unowned self] _ in
                
                self.dismiss(animated: true)
                
            })
            .disposed(by: viewModel.disposeBag)

        
        tableView.rx.didScroll
            .subscribe(onNext: { _ in
                
                self.tableView.setEditing(true, animated: true)

            })
            .disposed(by: viewModel.disposeBag)
        
        
    }
    
    func setUpcollectionView() {
        
        setUpDataSource()
       
        
    }

    func setUpDataSource() {
        
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfGenre>(configureCell: { dataSource, collectionView, indexPath, item  in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCell", for: indexPath) as! GenreCVCell

            cell.titleLbl.text = "# \(item.title)"

            collectionView.deselectItem(at: indexPath, animated: true)
            
            cell.configure()
            
            return cell
            
        })
        
        
        
    }
    
   
    
}

extension SearchGenresViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
           
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchGenreTxtViewTVCell", for: indexPath) as? SearchGenreTxtViewTVCell {
                
                cell.txtView.layer.borderWidth = 1
                cell.selectionStyle = .none
                
                if !viewModel.isDisplayed {
                
                    cell.txtView.text = viewModel.text

                    viewModel.isDisplayed = true

                    cell.txtView.rx.text
                        .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
                         .subscribe(onNext: { text in

                             if let text = text {
                                 
                                 self.viewModel.diffenceTxtSubject.onNext(text)
                                
                                 let textCount: Int = text.count
                                 guard textCount >= 1 else { return }
                                 cell.txtView.scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
                             }
                             
                           
                         })
                         .disposed(by: self.viewModel.disposeBag)
                    
                }
                
                return cell
            }
            
        }
        else if indexPath.row == 1 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchedGenresTVCell", for: indexPath) as? SearchedGenresTVCell {
                
                cell.selectionStyle = .none
                
                
                viewModel
                    .items
                    .bind(to: cell.collectionView.rx.items(dataSource: self.dataSource))
                    .disposed(by: viewModel.disposeBag)
                
                self.viewModel.selectedGenreSubject
                    .share(replay: 1, scope: .forever)
                    .withLatestFrom(Observable.combineLatest(self.viewModel.selectedGenreSubject, viewModel.searchingQuery.ifEmpty(default: ""), viewModel.diffenceTxtSubject.ifEmpty(default: "")))
                    .flatMapLatest { [unowned self] selectedGenre, query, txt in
                        self.viewModel.convertNewTxt(txt: txt, query: query, selectedGenre: selectedGenre)
                    }
                    .subscribe(onNext: { newString in

                        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SearchGenreTxtViewTVCell {
                                
                            cell.txtView.text = newString
                                
                        }
                        
                    })
                    .disposed(by: cell.disposeBag)

                cell.collectionView.rx.itemSelected
                    .withLatestFrom(Observable.combineLatest(cell.collectionView.rx.itemSelected, viewModel.items))
                    .subscribe(onNext: { [unowned self] collectionViewIndexPath, sections in

                        let items = sections[0].items
                        let item = items[collectionViewIndexPath.row]


                        var selectedGenres = self.viewModel.selectedGenres.value
                        selectedGenres.append(item)

                        self.viewModel.selectedGenreSubject.accept(item)
                        self.viewModel.selectedGenres.accept(selectedGenres)
                        

                        
                    })
                    .disposed(by: cell.disposeBag)
                
                
                return cell
            }
        }
        
        return UITableViewCell()
        
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
