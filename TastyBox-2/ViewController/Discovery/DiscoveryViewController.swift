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
import RxTimelane

//protocol MenuViewControllerDelegate: class {
//    func menuViewController(viewController: DiscoveryViewController, at index: Int)
//}

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
    
    
    //    var pageControllView = MainPageViewController()
    var cellUserTappedbefore: UICollectionViewCell?
    
    // 現在選択されている位置を状態として記憶しておくためのプロパティを作る
    var selectedIndex: Int = 1
    
    var pageVC: UIPageViewController?
    
    //
    //    let FollowingVC = UIStoryboard(name: "followingRecipe", bundle: nil).instantiateViewController(identifier: "followingRecipe") as! FollowingRecipeViewController
    //    let ingredientVC = UIStoryboard(name: "ingredientRecipe", bundle: nil).instantiateViewController(identifier: "ingredientRecipe") as! IngredientsViewController
//    let poppularVC = UIStoryboard(name: "popularPage", bundle: nil).instantiateViewController(identifier: "popularPage") as! PopularRecipeViewController
    //    let editorChoiceVC = UIStoryboard(name: "EditorChoice", bundle: nil).instantiateViewController(identifier: "EditorChoice") as EditorChoiceViewController
    //    let monthlyVC = UIStoryboard(name: "Monthly", bundle: nil).instantiateViewController(identifier: "Monthly") as! CuisineViewController
    //    let VIPVC = UIStoryboard(name: "VIP_page", bundle: nil).instantiateViewController(identifier: "VIP_page") as! VIPViewController
    //
    var indexPathUserselectedBefore: IndexPath?
    var indexPageCurledInContainer: Int?
    var PreviousIndexPageCurledInContainer: Int?
    
    var menuOpend = false
    
    var arrayMenu = [String]()
    var sideMenuOpen = false
    var lockObject = ActivityIndicator()
    
    //    weak var delegate: MenuViewControllerDelegate?
    
    @IBOutlet weak var SideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var MenuCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "TastyBox"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.9994645715, green: 0.9797875285, blue: 0.7697802186, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.orange]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
 
        
        CreateMenuLabel()
        
        initialContentView()
        
        viewModel.sideMenuTapped()
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name("ToggleSideMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSearch), name: NSNotification.Name("ShowSearch"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(AddRecipe), name: NSNotification.Name("AddRecipe"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(showLogout), name: NSNotification.Name("ShowLogout"), object: nil)
        
        //        pageControllView = self.children[0] as! MainPageViewController
        //        pageControllView.delegate = self
        self.MenuCollectionView.showsHorizontalScrollIndicator = false
        
        
        //        FollowingVC.delegate = self
        
        self.MenuCollectionView.reloadData()
        self.MenuCollectionView.layoutIfNeeded()
        self.MenuCollectionView.scrollToItem(at: NSIndexPath(item: selectedIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: true)
        
        self.navigationController?.hidesBarsOnTap = false
        
        self.navigationItem.backButtonTitle = ""
                
        viewModel.setDefaultViewControllers()
        
        pageVC = self.children.first as! UIPageViewController
        pageVC?.delegate = self
        
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
            .asDriver { err in
                return Driver.never()
            }
            .asObservable()
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
        
        
        self.MenuCollectionView.rx.itemSelected
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
            
            SideMenuConstraint.constant = -230 //-160
            
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
    
    func CreateMenuLabel() {
        
        let label1 = "Subscribed Creator"
        let label2 = "Your Ingredients Recipe"
        let label3 = "Most Popular"
//        let label4 = "Editor Choice"
//        let label5 = "Cuisine Choice"
//        let label6 = " VIP Only "
        arrayMenu.append(label1)
        arrayMenu.append(label2)
        arrayMenu.append(label3)
//        arrayMenu.append(label4)
//        arrayMenu.append(label5)
//        arrayMenu.append(label6)
    }
    
    
    func toggleSideMenu(isOpend: Bool) {
        
        SideMenuConstraint.constant = isOpend ? 0 : -230
        
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
            
            SideMenuConstraint.constant = -230 //-160
            
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
        
        if identifier == "addRecipe" {
            
            let navigationBar = UINavigationBar()
            let height = UIScreen.main.bounds.height / 2 - navigationBar.frame.size.height - 50
            let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            indicator.transform = CGAffineTransform(scaleX: 2, y: 2)
            indicator.center = CGPoint(x: UIScreen.main.bounds.width / 2 , y: height)
            indicator.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.5)
            indicator.color = .white
            indicator.layer.cornerRadius = 10
            
            self.view.bringSubviewToFront(indicator)
            
        }
        else if identifier == "toSideMenu" {
            
            viewModel.presenter.sideMenuVC = segue.destination as? SideMenuTableViewController
        }
        else if identifier == "showPageVC" {
           
            if let pageVC = segue.destination as? UIPageViewController {
            
                viewModel.presenter.pageVC = pageVC
    
            }

        }
        
    }
    
    @IBAction func SideMenuTapped(){
        print("Toggle side Menu")
        
        
        if sideMenuOpen == false {
            // Init a UIVisualEffectView which going to do the blur for us
            let blurView = UIVisualEffectView()
            // Make its frame equal the main view frame so that every pixel is under blurred
            blurView.frame = view.frame
            // Choose the style of the blur effect to regular.
            // You can choose dark, light, or extraLight if you wants
            blurView.effect = UIBlurEffect(style: .dark)
            // Now add the blur view to the main view
            blurView.tag = 100
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeSideMenu))
            blurView.addGestureRecognizer(tapRecognizer)
            
            self.view.insertSubview(blurView, at: 2)
        } else {
            
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            }
            
        }
        
        
    }
    
}


//extension DiscoveryViewController: FollowingRecipestopPagingDelegate {
//    func stopPaging(isPaging: Bool) {
//        self.pageControllView.isPaging = isPaging
//    }
//}



extension DiscoveryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = MenuCollectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCollectionViewCell
        let active = (indexPath.row == selectedIndex)
        cell.focusCell(active: active)
        cell.MenuLabel.text = arrayMenu[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        
        //        menuViewController(viewController: self.children[0] as! MainPageViewController, at: indexPath.row)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    //MARK:- MenuViewControllerDelegate
    //    func menuViewController(viewController: MainPageViewController, at index: Int) {
    //
    //        // 現在表示されているViewControllerを取得する
    //        var currentIndex: Int = 0
    //        //        //現在表示しているContentViewControllerを取得
    //        var vc: UIViewController?
    //
    //        let FollowingVC = UIStoryboard(name: "followingRecipe", bundle: nil).instantiateViewController(identifier: "followingRecipe") as! FollowingRecipeViewController
    //        let ingredientVC = UIStoryboard(name: "ingredientRecipe", bundle: nil).instantiateViewController(identifier: "ingredientRecipe") as! IngredientsViewController
    //        let popularVC = UIStoryboard(name: "popularPage", bundle: nil).instantiateViewController(identifier: "popularPage") as! PopularRecipeViewController
    //        let editorChoiceVC = UIStoryboard(name: "EditorChoice", bundle: nil).instantiateViewController(identifier: "EditorChoice") as EditorChoiceViewController
    //        let monthlyVC = UIStoryboard(name: "Monthly", bundle: nil).instantiateViewController(identifier: "Monthly") as! CuisineViewController
    //        let VIPVC = UIStoryboard(name: "VIP_page", bundle: nil).instantiateViewController(identifier: "VIP_page") as! VIPViewController
    //
    //        let Vcs = [FollowingVC, ingredientVC, popularVC, editorChoiceVC, monthlyVC, VIPVC]
    //        vc = Vcs[index]
    //
    //        if viewController.viewControllers?.first is FollowingViewController {
    //            currentIndex = 0
    //
    //        }
    //        else if viewController.viewControllers?.first is IngredientsViewController {
    //            currentIndex = 1
    //
    //        }
    //        else if viewController.viewControllers?.first is PopularRecipeViewController {
    //            currentIndex = 2
    //
    //        }
    //        else if viewController.viewControllers?.first is EditorChoiceViewController {
    //            currentIndex = 3
    //
    //        }
    //        else if viewController.viewControllers?.first is CuisineViewController {
    //            currentIndex = 4
    //
    //        }
    //        else if viewController.viewControllers?.first is VIPViewController {
    //            currentIndex = 5
    //
    //        }
    //
    //        // 選択したindexが表示しているコンテンツと同じなら処理を止める
    //        guard currentIndex != index else { return }
    //
    //        // 選択したindexと現在表示されているindexを比較して、ページングの方法を決める
    //        let direction : UIPageViewController.NavigationDirection = currentIndex < index ? .forward : .reverse
    //
    //        // 新しくViewControllerを設定する　※　下のスワイプと組み合わせる時はanimatedはfalseに設定しておいたほうが無難
    //        viewController.setViewControllers([vc!], direction: direction, animated: true)
    //
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        return CGSize(width: (self.view.frame.size.width - 5) / 5, height: MenuCollectionView.frame.size.height)
    //    }
    
    // 指定したindexPathのセルを選択状態にして移動させる。(collectionViewなので表示されていないセルは存在しない)
    func focusCell(indexPath: IndexPath) {
        // 以前選択されていたセルを非選択状態にする(collectionViewなので表示されていないセルは存在しない)
        if let previousCell = self.MenuCollectionView?.cellForItem(at: NSIndexPath(item: selectedIndex, section: 0) as IndexPath) as? MenuCollectionViewCell {
            previousCell.focusCell(active: false)
        }
        
        // 新しく選択したセルを選択状態にする(collectionViewなので表示されていないセルは存在しない)
        if let nextCell = self.MenuCollectionView?.cellForItem(at: indexPath) as? MenuCollectionViewCell {
            nextCell.focusCell(active: true)
        }
        // 現在選択されている位置を状態としてViewControllerに覚えさせておく
        selectedIndex = indexPath.row
        
        // .CenteredHorizontallyでを指定して、CollectionViewのboundsの中央にindexPathのセルが来るようにする
        self.MenuCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
}




class MenuCollectionViewCell: UICollectionViewCell{

    @IBOutlet weak var MenuLabel: UILabel!
    
    func focusCell(active: Bool) {
        let color = active ? #colorLiteral(red: 1, green: 0.9882352941, blue: 0.6549019608, alpha: 1) : #colorLiteral(red: 0.9882352941, green: 0.8862745098, blue: 0.4549019608, alpha: 1)
        self.contentView.backgroundColor = color
        let labelColor = active ? #colorLiteral(red: 0.6745098039, green: 0.5568627451, blue: 0.4078431373, alpha: 1) : #colorLiteral(red: 0.9960784314, green: 0.6509803922, blue: 0.1921568627, alpha: 1)
        MenuLabel.textColor = labelColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
            
            // MenuViewControllerの特定のセルにフォーカスをあてる
            let indexPath = IndexPath(row: index, section: 0)
            self.focusCell(indexPath: indexPath)
//            self.MenuCollectionView?.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)

            self.selectedIndex = index
            
        }

       
    }
    
}


