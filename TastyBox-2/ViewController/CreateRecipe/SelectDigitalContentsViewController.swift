//
//  SelectDegitalContentsViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-13.
//

import UIKit
import Photos
import RxSwift
import RxCocoa


class SelectDigitalContentsViewController: UIViewController, BindableType {
    
    typealias ViewModelType = SelectDigitalContentsVM
    var viewModel: SelectDigitalContentsVM!
    
    let cancelBtn = UIBarButtonItem()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .notDetermined {
            
            // Request permission to access photo library
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
                DispatchQueue.main.async { [unowned self] in
                    showUI(for: status)
                }
            }
            
        }
        
        
        collectionView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        collectionView.rx.setDataSource(self).disposed(by: viewModel.disposeBag)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CollectionViewFlowLayoutType(.photos, frame: view.frame).sizeForItem
        flowLayout.sectionInset = CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 1.0
        
        collectionView.collectionViewLayout = flowLayout
        
        cancelBtn.title = "Cancel"
        
        cancelBtn.rx.tap
            .subscribe(onNext: { [unowned self] in
                
                self.dismiss(animated: true) {
                    self.viewModel.sceneCoodinator.userDismissed()
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
        self.navigationItem.leftBarButtonItem = cancelBtn
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.viewModel.sceneCoodinator.userDismissed()
        
    }
    
    func bindViewModel() {
        
        self.viewModel.fetchContents(kind: viewModel.kind)
        
        
    }
    
    
    
    func showUI(for status: PHAuthorizationStatus) {
        
        switch status {
        case .authorized:
            print("authrized")
            
        case .limited:
            print("limited")
            
        case .restricted:
            print("restricted")
            
        case .denied:
            print("denied")
            
        case .notDetermined:
            break
            
        @unknown default:
            break
        }
    }
    
}

extension SelectDigitalContentsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.assets.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectDegitalContentsCVCell", for: indexPath) as? SelectDigitalContentsCVCell {
            
            let asset = viewModel.assets[indexPath.row]
            cell.contentImgView.fetchImageAsset(asset, targetSize: cell.contentImgView.bounds.size, completionHandler: nil)
            cell.selectedNumImgView.isHidden = true
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}


struct CollectionViewFlowLayoutType {
    enum ViewType { case album, photos }
    
    private var viewType: ViewType = .album
    private var viewFrame: CGRect = .zero
    var itemsPerRow: CGFloat {
        switch viewType {
        case .album: return 2
        case .photos: return 3
        }
    }
    var sectionInsets: UIEdgeInsets {
        switch viewType {
        case .album: return UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
        case .photos: return UIEdgeInsets(top: 0.0, left: 2.0, bottom: 0.0, right: 2.0)
        }
    }
    var sizeForItem: CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = viewFrame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    init(_ type: ViewType, frame: CGRect) {
        viewType = type
        viewFrame = frame
    }
}
