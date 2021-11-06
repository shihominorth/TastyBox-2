//
//  GenreTableView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-23.
//

import UIKit
import RxSwift
import RxCocoa
import RxTimelane

class GenreTVCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    let flowLayout = GenreCollectionViewFlowLayout()
//    let dataSource = RxGenreCollectionViewDataSource<Genre, RecipeGenresCVCell>(identifier: "RecipeGenre") { index, element, cell in
//
//        cell.nameLbl.text = "# \(element.title)"
//
//    }

    
    let genres = PublishSubject<[Genre]>()
    var disposeBag = DisposeBag()
    
    
    override var reuseIdentifier: String? {
        return "GenreTVCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        disposeBag = DisposeBag()
    }
    
    func configure() {
        


//        genres
////                    .lane("genre uploading")
//            .debug()
////            .asDriver(onErrorJustReturn: [])
//            .observe(on: MainScheduler.instance)
//            .bind(to: collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
        
        
    }

}
