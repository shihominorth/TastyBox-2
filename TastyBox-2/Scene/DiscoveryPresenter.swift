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
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    private var currentViewController: UIViewController?
    var pageVC: UIPageViewController?
    var sideMenuVC: SideMenuTableViewController?
    

    required init(user: Firebase.User, sceneCoordinator: SceneCoordinator) {
        
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        
        
        let vm = RankingVM(user: self.user)
        let scene = MainScene.ranking(vm)
        let rankingVC = scene.viewController()
        self.viewControllers = [rankingVC, rankingVC, rankingVC, rankingVC, rankingVC]
                
      
    }
    
    func setDefaultViewController() {
       
        pageVC?.setViewControllers([viewControllers[2]], direction: .forward, animated: true, completion: { [unowned self] isCompleted in
            
            if isCompleted {
                
                self.currentViewController = viewControllers[2]
                
                if let rankingVC = self.currentViewController as? RankingViewController {
                    
                    rankingVC.viewModel.delegate = self

                }
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


extension DiscoveryPresenter: RankingVMDelegate {
    
    func selectedRecipe(recipe: Recipe) {
        
        let vm = RecipeVM(sceneCoordinator: self.sceneCoordinator, user: self.user, recipe: recipe)
        let scene: Scene = .recipeScene(scene: .recipe(vm))
        
        self.sceneCoordinator.modalTransition(to: scene, type: .push)
        
    }
    
}
