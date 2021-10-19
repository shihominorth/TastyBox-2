//
//  EditMainImageTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class EditMainImageTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var mainImgDataSubject = PublishSubject<Data>()
    var thumbnailDataSubject = PublishSubject<Data>()
   
    var mainImage = UIImage(named: "PhotoUpload")
    var thumbnailImg = UIImage(named: "VideoUpload")
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize =  CGSize(width: self.contentView.frame.width, height: self.contentView.frame.width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        collectionView.backgroundColor = hexStringToUIColor(hex: "#FEFACA")
        
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        collectionView.dataSource = self
        
        mainImgDataSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] data in
                
                self.mainImage = UIImage(data: data)
                self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
                
            }, onError: { err in
                
                print(err)
                
            })
            .disposed(by: disposeBag)
        
        thumbnailDataSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] data in
                
                self.thumbnailImg = UIImage(data: data)
                self.collectionView.reloadItems(at: [IndexPath(row: 1, section: 0)])
                
            }, onError: { err in
                
                print(err)
                
            })
            .disposed(by: disposeBag)

    }

    func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    

}

extension EditMainImageTVCell: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
          
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "editMainImageCVCell", for: indexPath) as! EditMainImageCVCell
            
            cell.imgView.image = mainImage
            
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editMainVideoCVCell", for: indexPath) as! EditMainVideoCVCell
           
            cell.imgView.image = thumbnailImg
              
            return cell
        }
    }
    
}

