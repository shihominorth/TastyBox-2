//
//  DiscoveryPresenter.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-15.
//

import UIKit
import Firebase
import RxCocoa
import RxSwift


class DiscoveryPresenter: NSObject {

    private var viewControllers: [UIViewController]
    private var currentViewController: UIViewController?
    var pageVC: UIPageViewController?
    var sideMenuVC: SideMenuTableViewController?

    required init(user: Firebase.User) {
                
        let vm = RankingVM(user: user)
        let scene = MainScene.ranking(vm)
        
        let rankingVC = scene.viewController()
        
        self.viewControllers = [rankingVC, rankingVC, rankingVC, rankingVC, rankingVC]
        
    }
    
    func setDefaultViewController() {
       
        pageVC?.setViewControllers([viewControllers[2]], direction: .forward, animated: true, completion: { [unowned self] isCompleted in
            
            if isCompleted {
                self.currentViewController = viewControllers[2]
            }
            
        })
    }
    
    
    func setViewControllers(scene: MainScene) {
       
        let viewController = scene.viewController()

        pageVC?.setViewControllers([viewController], direction: .forward, animated: true, completion: { [unowned self] isCompleted in
            
            if isCompleted {
                self.currentViewController = viewController
            }
            
        })
    }
    
 
}

