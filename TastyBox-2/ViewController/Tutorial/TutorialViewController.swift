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
        
        self.generateExplanations()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false

    }
    
    func bindViewModel() {
        
       
        
    }
    
    func generateExplanations() {
        
        guard let firstImage = UIImage(named: "food_spaghetti_vongole_bianco") else { return }
        let first = Tutorial(title: "Find creative and tasty recipes!", image: firstImage, explanation: "You can find recipes from TastyBox!")
        
        self.viewModel.explainations.append(first)
        
        guard let secondImage = UIImage(named: "food_spaghetti_vongole_bianco") else { return }
        let second = Tutorial(title: "Follow your favorite publishers!", image: secondImage, explanation: "Check the latest recipes")
        
        self.viewModel.explainations.append(second)
        
        guard let thirdImage = UIImage(named: "food_spaghetti_vongole_bianco") else { return }
        let third = Tutorial(title: "Find the recipes that your ingredients is used!", image: thirdImage, explanation: "You can know the recipes each ingredients you have are used.")
        
        
        self.viewModel.explainations.append(third)
        
        
        guard let fourthImage = UIImage(named: "food_spaghetti_vongole_bianco") else { return }
        let fourth = Tutorial(title: "Aim to get the top likes!", image: fourthImage, explanation: "Everyone can like the recipe, ")
        
        self.viewModel.explainations.append(fourth)
        
        pageControl.numberOfPages = self.viewModel.explainations.count
        
    }
    
}

extension TutorialViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.viewModel.explainations.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
        switch indexPath.row {

        case viewModel.explainations.count:
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "start", for: indexPath) as! StartCVCell
            
            cell.configureCell()
//            cell.signUpwithAccountBtn.rx.action = viewModel.toSignUpAction()
            
            cell.signUpwithAccountBtn.rx.tap
                .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
                .do(onNext: {
                    UserDefaults.standard.set(true, forKey: "isTutorialDone")
                })
                .subscribe(onNext: { [unowned self] in
                    
                    self.viewModel.toLogin()
                    
                })
                .disposed(by: cell.disposeBag)

            return cell
            
        default:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCVCell", for: indexPath) as! TutorialCVCell
            
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 30.0
            cell.layer.borderColor = #colorLiteral(red: 0.7019607843, green: 0.6980392157, blue: 0.5019607843, alpha: 1)
            
            
            cell.contextLbl.text = self.viewModel.explainations[indexPath.row].explanation
            cell.titleLbl.text = self.viewModel.explainations[indexPath.row].title
            
            
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
