//
//  DiscoveryViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-16.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
//import Crashlytics
import RxSwift
import RxCocoa


class DiscoveryViewController: UIViewController, BindableType {
    
    
    typealias ViewModelType = DiscoveryVM
    
    var viewModel: DiscoveryVM!
    
    @IBOutlet weak var menuNavBtn: UIBarButtonItem!
    @IBOutlet weak var addRecipeNavBtn: UIBarButtonItem!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sideMenuContainerView: UIView!
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    
    var pageVC: UIPageViewController?

    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "TastyBox"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.9994645715, green: 0.9797875285, blue: 0.7697802186, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.orange]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
 
                
        initialContentView()
        
        viewModel.sideMenuTapped()
        
        // 後ほどリアクティブに
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name("ToggleSideMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSearch), name: NSNotification.Name("ShowSearch"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(AddRecipe), name: NSNotification.Name("AddRecipe"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(showLogout), name: NSNotification.Name("ShowLogout"), object: nil)

        self.menuCollectionView.showsHorizontalScrollIndicator = false
        
        // 将来的にTwitterのnavigation barような挙動にする
        self.navigationController?.hidesBarsOnTap = false
        
                
        viewModel.setDefaultViewControllers()
        
        pageVC = (self.children.first as! UIPageViewController)
        pageVC?.delegate = self
        
        self.menuCollectionView.scrollToItem(at: NSIndexPath(item: viewModel.selectedIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: true)

        
    }
    
     
    override func viewWillDisappear(_ animated: Bool) {
        
        disappearSideMenu()
    }
    
    
    func bindViewModel() {
        
        self.addRecipeNavBtn.rx.tap
            .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
            .debug("add recipe btn")
            .subscribe(onNext: { [unowned self] in self.viewModel.toCreateRecipeVC() })
            .disposed(by: viewModel.disposeBag)
        
        self.menuNavBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .catch { err in
                return .empty()
            }
            .flatMap { [unowned self] in self.viewModel.setIsMenuBarOpenedRelay() }
            .subscribe(onNext: { [unowned self] isOpened in
                
                self.toggleSideMenu(isOpend: isOpened)
                
                if isOpened {
                    self.insertblurView()
                }
                else {
                    self.removeBlurView()
                }
                
            }, onError: { err in
                print(err)
            })
            .disposed(by: viewModel.disposeBag)
  

        
        self.menuCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in

                self.focusCell(indexPath: indexPath)
                self.viewModel.selectPageTitle(row: indexPath.row)
                

            })
            .disposed(by: viewModel.disposeBag)

    }
    
    
    fileprivate func disappearSideMenu() {
       
        if let viewWithTag = self.view.viewWithTag(100) {
            
            viewWithTag.removeFromSuperview()
            //            sideMenuOpen = false
            viewModel.isMenuBarOpenedRelay.accept(false)
            
            sideMenuConstraint.constant = -230 //-160
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @IBAction func SearchBarItem() {
        print("Tab search Button")
        NotificationCenter.default.post(name: NSNotification.Name("ShowSearch"), object: nil)
    }
    
    
    func initialContentView(){
        
        self.containerView.isHidden = false
        
    }
    

    
    func toggleSideMenu(isOpend: Bool) {
        
        sideMenuConstraint.constant = isOpend ? 0 : -230
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func insertblurView()  {
        
        
        // Init a UIVisualEffectView which going to do the blur for us
        let blurView = UIVisualEffectView()
        // Make its frame equal the main view frame so that every pixel is under blurred
        blurView.frame = view.frame
        // Choose the style of the blur effect to regular.
        // You can choose dark, light, or extraLight if you wants
        blurView.effect = UIBlurEffect(style: .dark)
        
        blurView.alpha = 0.3
        
        // Now add the blur view to the main view
        blurView.tag = 100
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeSideMenu))
        blurView.addGestureRecognizer(tapRecognizer)
        
        self.view.insertSubview(blurView, at: 2)
        
        
        
    }
    
    
    func removeBlurView() {
        
        if let viewWithTag = self.view.viewWithTag(100) {
            
            viewWithTag.removeFromSuperview()
            
        }
    }
    
    
    
    @objc func closeSideMenu() {
        
        if let viewWithTag = self.view.viewWithTag(100) {
            
            viewWithTag.removeFromSuperview()
            
            sideMenuConstraint.constant = -230 //-160
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func showSearch(){
        UIView.animate(withDuration: 1.0) {
            print("show Search")
            guard self.navigationController?.topViewController == self else { return }
            self.performSegue(withIdentifier: "searchPage", sender: nil)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        guard let identifier = segue.identifier else { return }

        if identifier == "toSideMenu" {
            
            //これはsegueでやった方が楽
            viewModel.presenter.sideMenuVC = segue.destination as? SideMenuTableViewController
        }
        else if identifier == "showPageVC" {
           
            if let pageVC = segue.destination as? UIPageViewController {
            
                viewModel.presenter.pageVC = pageVC
    
            }

        }
        
    }
    
    
}


extension DiscoveryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCollectionViewCell
        cell.MenuLabel.text = viewModel.pages[indexPath.row]
        
        let active = (indexPath.row == viewModel.selectedIndex)
        cell.focusCell(active: active)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    //なぜここをリアクティブ化しないのか？
    
    //  self.viewModel.selectPageTitle(row: indexPath.row)があるかどうか
    //　わざわざIndexPath（タップされた場合）かInt型（pageVCがスクロールされた場合）に変換しないといけない
    
    // 分けた方がわかりやすいのでは？

    
    // 指定したindexPathのセルを選択状態にして移動させる。(collectionViewなので表示されていないセルは存在しない)
    func focusCell(indexPath: IndexPath) {
        // 以前選択されていたセルを非選択状態にする(collectionViewなので表示されていないセルは存在しない)
        if let previousCell = self.menuCollectionView?.cellForItem(at: NSIndexPath(item: viewModel.selectedIndex, section: 0) as IndexPath) as? MenuCollectionViewCell {
            previousCell.focusCell(active: false)
        }
        
        // 新しく選択したセルを選択状態にする(collectionViewなので表示されていないセルは存在しない)
        if let nextCell = self.menuCollectionView?.cellForItem(at: indexPath) as? MenuCollectionViewCell {
            nextCell.focusCell(active: true)
        }
        // 現在選択されている位置を状態としてViewControllerに覚えさせておく
        viewModel.selectedIndex = indexPath.row
        
        // .CenteredHorizontallyでを指定して、CollectionViewのboundsの中央にindexPathのセルが来るようにする
        self.menuCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
}




class MenuCollectionViewCell: UICollectionViewCell{

    @IBOutlet weak var MenuLabel: UILabel!
    var disposeBag = DisposeBag()
    
    func focusCell(active: Bool) {
        let color = active ? #colorLiteral(red: 1, green: 0.9882352941, blue: 0.6549019608, alpha: 1) : #colorLiteral(red: 0.9882352941, green: 0.8862745098, blue: 0.4549019608, alpha: 1)
        self.contentView.backgroundColor = color
        let labelColor = active ? #colorLiteral(red: 0.6745098039, green: 0.5568627451, blue: 0.4078431373, alpha: 1) : #colorLiteral(red: 0.9960784314, green: 0.6509803922, blue: 0.1921568627, alpha: 1)
        MenuLabel.textColor = labelColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disposeBag = DisposeBag()
    }
    
}

extension DiscoveryViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        var index = 0

        if let currentViewController = pageViewController.viewControllers?.first {

            if currentViewController is TimelineViewController {

                index = 0

            }
            else if currentViewController is IngredientsViewController {
                index = 1
            }
            else if currentViewController is RankingViewController {

                index = 2
            }

//            // MenuViewControllerの特定のセルにフォーカスをあてる
            let indexPath = IndexPath(row: index, section: 0)
            self.focusCell(indexPath: indexPath)
            self.menuCollectionView?.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)


        }


    }

}


