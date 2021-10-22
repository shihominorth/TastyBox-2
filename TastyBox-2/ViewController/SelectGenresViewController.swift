//
//  SelectGenresViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SelectGenresViewController: UIViewController, BindableType {
    
    typealias ViewModelType = SelectGenresVM
    var viewModel: SelectGenresVM!
    
    let addBtn = UIBarButtonItem()
    let cancelBtn = UIBarButtonItem()
    
//    let headerView = GenresTableHeaderView()
    
    var dataSource: RxCollectionViewSectionedReloadDataSource<SectionOfGenre>!
    
    var headerView: SearchBarRCV!
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    let flowLayout = GenreCollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
        self.navigationController?.navigationItem.rightBarButtonItem = addBtn
        self.navigationController?.navigationItem.leftBarButtonItem = cancelBtn
        
        setUpCollectionView()
        setUpDataSource()
       
    }

    
    override func viewWillDisappear(_ animated: Bool) {
       
        self.viewModel.sceneCoordinator.userDissmissed(viewController: self)
    
    }
    
    func bindViewModel() {
        
        
        let sectionOfGenres = SectionOfGenre(header: "", items: [Genre(id: "", title: "dummy"), Genre(id: "", title: "dummy2")])
        
//        viewModel.differenceSubject.onNext([sectionOfGenres])
        viewModel.items.accept([sectionOfGenres])
        
//        Observable.combineLatest(viewModel.searchTextSubject, viewModel.items) { query, items in
//                self.viewModel.filterSearchedItems(with: items, query: query)
//            }
//            .bind(to: collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: viewModel.disposeBag)
        
        viewModel.items
//            .startWith([])
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
//        viewModel.getGenre()
        
//        let isQueryEmpty = viewModel.searchTextSubject.skip(1)
//            .flatMap { [unowned self] in
//            self.viewModel.isQueryEmpty(query: $0)
//        }
//            .flatMap  { [unowned self] in
//                self.viewModel.hasGenre(query: $0)
//            }
        
        
//        let shouldAddNewGenreSubject = viewModel.shouldAddNewGenre.filter { $0 }
//            .withLatestFrom(isQueryEmpty)
//            .flatMap { [unowned self] query in
//                self.viewModel.addNewGenre(query: query)
//            }
//
//        let shouldNotAddNewGenreSubject = viewModel.shouldAddNewGenre.filter { !$0 }.withLatestFrom(isQueryEmpty)
//            .flatMap { [unowned self] query in
//                self.viewModel.changeNewGenre(query: query)
//            }
        
        
        
        
//        Observable.combineLatest(viewModel.searchTextSubject, shouldAddNewGenreSubject)
//            .map { query, items in
//                self.viewModel.filterSearchedItems(with: items, query: query)
//            }
//            .bind(to: collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: viewModel.disposeBag)
        
    }
    
    func setUpDataSource() {
        
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfGenre>(configureCell: { dataSource, collectionView, indexPath, item  in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCell", for: indexPath) as! GenreCVCell
            cell.titleLbl.text = "# \(item.title)"
            
            
            return cell
        })
        
        
        dataSource.configureSupplementaryView = { [unowned self] dataSource, collectionView, kind, indexPath in
            
            if kind == "UICollectionElementKindSectionHeader" {
                
                switch indexPath.section {
                case 0:
                    
                    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchBarCV", for: indexPath) as! SearchBarRCV
                    
                    view.searchBar.rx.text
                        .orEmpty
                        .distinctUntilChanged()
                        .bind(to: self.viewModel.searchTextSubject)
                        .disposed(by: view.disposeBag)
                  
                    
                    return view
                    
                default:
                    break
                }
                
            }
            
            return UICollectionReusableView()
            
        }
                
        
        dataSource.canMoveItemAtIndexPath = { dataSource, indexPath in
            return false
        }
     
    }
    
    func setUpCollectionView() {

       
        self.collectionView.register(UINib(nibName: "SearchBarRCV", bundle: nil), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "SearchBarRCV")

        self.collectionView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        
        
        collectionView.rx.didScroll
            .asDriver()
            .do(onNext: { _ in
                
                self.setEditing(false, animated: true)
                
            })
                .drive()
                .disposed(by: viewModel.disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                    
                let cell = collectionView.cellForItem(at: indexPath) as! GenreCVCell
                cell.setIsSelectedGenre()
                    
            })
            .disposed(by: viewModel.disposeBag)
                
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.minimumInteritemSpacing = collectionView.bounds.height
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                
        collectionView.collectionViewLayout = flowLayout
                
    }
    
}

extension SelectGenresViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
}



