//
//  TutorialViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-17.
//

import UIKit
import RxSwift
import RxCocoa

class TutorialViewController: UIViewController, BindableType {
    
    typealias ViewModelType = TutorialVM
    var viewModel: TutorialVM!
    
    //    for tutorials creation
    //    https://techlife.cookpad.com/entry/2019/08/16/090000
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var cellSize: CGSize {
        let width = collectionView.bounds.width * 0.8
//        let height = width * TutorialCVCell.aspectRatio
        let height = collectionView.bounds.height * 0.95

        return CGSize(width: width, height: height)
    }
    
    
    private var headerSize: CGSize {
        let width = collectionView.bounds.width * 0.83
        return CGSize(width: width, height: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        let nib = UINib(nibName: "StartCVCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "start")

        let flowLayout = FlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = cellSize
        flowLayout.minimumInteritemSpacing = collectionView.bounds.height
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        collectionView.rx.setDataSource(self).disposed(by: viewModel.disposeBag)
        
        pageControl.numberOfPages = 5
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        
    }
    
    func bindViewModel() {
        
    }
    
    
}

extension TutorialViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
        switch indexPath.row {

        case 5:
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "start", for: indexPath) as! StartCVCell
            cell.configureCell()

            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCVCell", for: indexPath) as! TutorialCVCell
            
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 30.0
            cell.layer.borderColor = #colorLiteral(red: 0.7019607843, green: 0.6980392157, blue: 0.5019607843, alpha: 1)
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind _: String, at indexPath: IndexPath) -> UICollectionReusableView {
          return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
      }
}

extension TutorialViewController: UICollectionViewDelegateFlowLayout {
   
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let collectionView = scrollView as! UICollectionView
        guard let flowLayout = collectionView.collectionViewLayout as? FlowLayout else {
            return
        }
        flowLayout.prepareForPaging()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionView = scrollView as! UICollectionView
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
        
        if let visibleIndex = visibleIndexPath?.row  {
            pageControl.currentPage = visibleIndex
        }
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return headerSize
    }
}
