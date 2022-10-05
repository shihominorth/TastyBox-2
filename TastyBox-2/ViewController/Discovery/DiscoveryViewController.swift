//
//  DiscoveryViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-16.
//

import Firebase
import FirebaseAuth
//import FBSDKLoginKit
import RxCocoa
import RxSwift
import UIKit


final class DiscoveryViewController: UIViewController, BindableType {
    
    typealias ViewModelType = DiscoveryViewModel
    
    var viewModel: DiscoveryViewModel!
    
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
        
        setUpViews()
        
        viewModel.sideMenuTapped()
        viewModel.setDefaultViewControllers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSearch), name: NSNotification.Name("ShowSearch"), object: nil)
        
        setUpMenuCollectinoView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disappearSideMenu()
    }
    
    func bindViewModel() {
        self.addRecipeNavBtn.rx.tap
            .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
            .catch { err in
                return .empty()
            }
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
            })
            .disposed(by: viewModel.disposeBag)
        
        self.menuCollectionView.rx.itemSelected
            .catch { err in
                return .empty()
            }
            .subscribe(onNext: { [unowned self] indexPath in
                self.viewModel.selectPageTitle(row: indexPath.row)
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    private func setUpViews() {
        setUpNavigationBar()
        initialContentView()
        setUpPageViewController()
    }
    
    func setUpNavigationBar() {
        
        self.title = "TastyBox"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.9994645715, green: 0.9797875285, blue: 0.7697802186, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.orange]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        self.navigationController?.hidesBarsOnTap = false
        
    }
    
    func setUpPageViewController() {
        guard let pageViewController = self.children.first as? UIPageViewController else {
            return
        }
        pageViewController.delegate = self
    }
    
    private func setUpMenuCollectinoView() {
        self.menuCollectionView.showsHorizontalScrollIndicator = false
        
        self.menuCollectionView.scrollToItem(at: IndexPath(item: viewModel.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    private func disappearSideMenu() {
        
        guard let viewWithTag = self.view.viewWithTag(100) else {
            return
        }
        viewWithTag.removeFromSuperview()
        viewModel.isMenuBarOpenedRelay.accept(false)
        
        sideMenuConstraint.constant = -230 //-160
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
        guard let viewWithTag = self.view.viewWithTag(100) else {
            return
        }
        viewWithTag.removeFromSuperview()
    }
    
    @objc func closeSideMenu() {
        
        guard let viewWithTag = self.view.viewWithTag(100) else {
            return
        }
        viewWithTag.removeFromSuperview()
        
        sideMenuConstraint.constant = -230 //-160
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func showSearch(){
        UIView.animate(withDuration: 1.0) {
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
    
    //なぜここをリアクティブ化しないのか？
    
    //  self.viewModel.selectPageTitle(row: indexPath.row)があるかどうか
    //　わざわざIndexPath（タップされた場合）かInt型（pageVCがスクロールされた場合）に変換しないといけない
    
    // 分けた方がわかりやすいのでは？
    
    
    // 指定したindexPathのセルを選択状態にして移動させる。(collectionViewなので表示されていないセルは存在しない)
    func focusCell(indexPath: IndexPath) {
        // 以前選択されていたセルを非選択状態にする(collectionViewなので表示されていないセルは存在しない)
//        if let previousCell = self.menuCollectionView?.cellForItem(at: IndexPath(item: viewModel.selectedIndex, section: 0)) as? MenuCollectionViewCell {
//            previousCell.focusCell(active: false)
            // 現在選択されている位置を状態としてViewControllerに覚えさせておく
            viewModel.selectedIndex = indexPath.row
//        }
        
        // 新しく選択したセルを選択状態にする(collectionViewなので表示されていないセルは存在しない)
//        if let nextCell = self.menuCollectionView?.cellForItem(at: indexPath) as? MenuCollectionViewCell {
//            nextCell.focusCell(active: true)
//        }
        // .CenteredHorizontallyでを指定して、CollectionViewのboundsの中央にindexPathのセルが来るようにする
        self.menuCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
}

extension DiscoveryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as? MenuCollectionViewCell else {
            return .init()
        }
        cell.MenuLabel.text = viewModel.pages[indexPath.row]
                
        if indexPath.row == 1 {
            cell.focusCell(active: true)
        }
        
        collectionView.rx.itemSelected
            .map { $0.row == indexPath.row }
            .bind(to: cell.isSelectedBehavoirSubject)
            .disposed(by: cell.disposeBag)
                
        return cell
    }
}

extension DiscoveryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}


extension DiscoveryViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        var index = 0
        
        guard let currentViewController = pageViewController.viewControllers?.first else {
            return
        }
        
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
        self.menuCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
    }
    
}


