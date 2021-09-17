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
        let height = width * TutorialCVCell.aspectRatio
        return CGSize(width: width, height: height)
    }
    
    
    private var headerSize: CGSize {
        let width = collectionView.bounds.width * 0.6
        return CGSize(width: width, height: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = cellSize
        flowLayout.minimumInteritemSpacing = collectionView.bounds.height
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        
        
        
        collectionView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        collectionView.rx.setDataSource(self).disposed(by: viewModel.disposeBag)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCVCell", for: indexPath) as! TutorialCVCell
    }
    
}

extension TutorialViewController: UICollectionViewDelegateFlowLayout {
   
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let collectionView = scrollView as! UICollectionView
        (collectionView.collectionViewLayout as! FlowLayout).prepareForPaging()
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return headerSize
    }
}
