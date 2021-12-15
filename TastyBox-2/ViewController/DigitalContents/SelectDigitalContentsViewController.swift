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
import SCLAlertView


class SelectDigitalContentsViewController: UIViewController, BindableType {
    
    typealias ViewModelType = SelectDigitalContentsVM
    var viewModel: SelectDigitalContentsVM!
    
    let segmentControl = UISegmentedControl(items: ["Images", "Videos"])
    
    let cancelBtn = UIBarButtonItem()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        
        let status = PHPhotoLibrary.authorizationStatus()

        if status == .notDetermined {
            
            // Request permission to access photo library
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
                DispatchQueue.main.async { [unowned self] in
                    showUI(for: status)
                }
            }
            
            
        }
        
        if status == .denied {
            
            
            SCLAlertView().showTitle(
                "Allow Access Your Photo Library", // Title of view
                subTitle: "Go to Settings -> TastyBox -> Photos",
                timeout: .none, // String of view
                completeText: "Done", // Optional button value, default: ""
                style: .notice, // Styles - see below.
                colorStyle: 0xA429FF,
                colorTextButton: 0xFFFFFF
            )
            
        }
        
        
        collectionView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
        collectionView.rx.setDataSource(self).disposed(by: viewModel.disposeBag)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CollectionViewFlowLayoutType(.photos, frame: view.frame).sizeForItem
        flowLayout.sectionInset = CollectionViewFlowLayoutType(.photos, frame: view.frame).sectionInsets
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 1.0
//        flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.width, height: 50.0)
        
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.register(SelectDigitalHeaderRCV.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "select digital contents header view")
        
        cancelBtn.title = "Cancel"
        
        cancelBtn.rx.tap
            .subscribe(onNext: { [unowned self] in
                
                self.dismiss(animated: true) {
                    self.viewModel.sceneCoodinator.userDismissed()
                }
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        self.navigationItem.leftBarButtonItem = cancelBtn
        
        segmentControl.selectedSegmentIndex = 0
        
        
        self.navigationItem.titleView = segmentControl
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        self.viewModel.sceneCoodinator.userDismissed()
        
    }
    
    deinit {
        
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    
    }
    
    func bindViewModel() {
        
        self.viewModel.fetchContents(kind: viewModel.kind)
        
        self.segmentControl.rx.selectedSegmentIndex
            .skip(1)
            .distinctUntilChanged()
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] row in
            

                self.collectionView.performBatchUpdates({

                    if row == 0 {

                        self.viewModel.kind = .recipeMain(.image)
                        self.viewModel.fetchContents(kind: .recipeMain(.image))

                    }
                    else {

                        self.viewModel.kind = .recipeMain(.video)
                        self.viewModel.fetchContents(kind: .recipeMain(.video))

                    }

                }) { success in

                    UIView.transition(with: collectionView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.collectionView.reloadData()}, completion: nil)

                }

            })
            .disposed(by: viewModel.disposeBag)
        
        collectionView.rx.itemSelected
            .map { [unowned self] indexPath in
                self.viewModel.assets[indexPath.row]
            }
            .subscribe(onNext: { [unowned self] in
                
                switch self.viewModel.kind {
                
                case .recipeMain(.video):
                
                    self.viewModel.toSelectVideoVC(asset: $0)
                
                default:
                  
                    self.viewModel.toSelectImageVC(asset: $0)
                    
                }
              
            })
            .disposed(by: viewModel.disposeBag)
        
        
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
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 0  {
//
//            switch viewModel.kind {
//            case .recipeMain:
//
//                if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "select digital contents header view", for: indexPath) as? SelectDigitalHeaderRCV {
//
//                    headerView.segmentControl.selectedSegmentIndex = 0
//
//                    headerView.addSubview(headerView.segmentControl)
//
//                    headerView.segmentControl.translatesAutoresizingMaskIntoConstraints = false
//
//                    headerView.segmentControl.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
//                    headerView.segmentControl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
//
//
//                    headerView.segmentControl.rx.selectedSegmentIndex
//                        .skip(1)
//                        .distinctUntilChanged()
//                        .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
//                        .subscribe(onNext: { [unowned self] row in
//
//                            self.collectionView.performBatchUpdates({
//
//                                if row == 0 {
//
//                                    self.viewModel.kind = .recipeMain(.image)
//                                    self.viewModel.fetchContents(kind: .recipeMain(.image))
//
//                                }
//                                else {
//
//                                    self.viewModel.kind = .recipeMain(.video)
//                                    self.viewModel.fetchContents(kind: .recipeMain(.video))
//
//                                }
//
//                            }) { success in
//
//                                collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
//
//                            }
//
//                        })
//                        .disposed(by: viewModel.disposeBag)
//
//                    return headerView
//                }
//
//            default:
//                break
//            }
//
//
//        }
//
//        return UICollectionReusableView()
//    }
    
}

extension SelectDigitalContentsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // 1
        guard let change = changeInstance.changeDetails(for: self.viewModel.assets) else {
            return
        }
        DispatchQueue.main.sync { [unowned self] in
            // 2
            self.viewModel.assets = change.fetchResultAfterChanges
            collectionView.reloadData()
        }
        
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


