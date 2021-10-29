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
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: RxCollectionViewSectionedReloadDataSource<SectionOfGenre>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        
        setUpcollectionView()
        
        viewModel.items
            .bind(to: collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: viewModel.disposeBag)
        
        viewModel.diffenceTxtSubject
            .subscribe(onNext: { text in
                
                print(text)
                
            })
            .disposed(by: viewModel.disposeBag)
        

        
    }
    
    func setUpcollectionView() {
        
        setUpDataSource()
        
        let flowLayout = GenreCollectionViewFlowLayout()
        
        flowLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 100)

        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)

        collectionView.collectionViewLayout = flowLayout
        
        collectionView.rx.didScroll
            .subscribe(onNext: { [unowned self] in
                
                self.collectionView.endEditing(true)
                
            })
            .disposed(by: viewModel.disposeBag)
    }

    func setUpDataSource() {
        
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfGenre>(configureCell: { dataSource, collectionView, indexPath, item  in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCell", for: indexPath) as! GenreCVCell
            cell.titleLbl.text = "# \(item.title)"
            
            if self.viewModel.selectedGenres.value.filter({ $0.id == item.id }).isNotEmpty {
                cell.isSelectedGenre = true
            }
            else {
                cell.isSelectedGenre = false
            }
            
            cell.configure()
            
            return cell
        }, configureSupplementaryView: { [unowned self] dataSource, collectionView, kind, indexPath in
            
            switch indexPath.section {
            case 0:
                
                if (kind == "UICollectionElementKindSectionHeader") {
                    let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "selectGenresCRV", for: indexPath) as! SelectGenresCRV
                    
                    reusableView.txtView.layer.borderWidth = 1
                    
                    if !viewModel.isDisplayed {
                    
                        reusableView.txtView.text = viewModel.text
                        viewModel.isDisplayed = true
                    
                    }
                   
                    
                    reusableView.txtView.rx.text
                        .subscribe(onNext: {  text in

                            if let text = text {
                                
                                self.viewModel.diffenceTxtSubject.onNext(text)
                               
                                let textCount: Int = text.count
                                guard textCount >= 1 else { return }
                                reusableView.txtView.scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
                            }

                            
                        })
                        .disposed(by: self.viewModel.disposeBag)

                    return reusableView
                }
                
            default:
                break
            }
            
            return UICollectionReusableView()
        })
        
        
    }
    
   
    
}
