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
        
        let ingredientsVM = IngredientsVM(user: self.user)
        let ingredientsVC = MainScene.ingredients(ingredientsVM).viewController()
        
        let rankingVM = RankingVM(user: self.user)
        let rankingVC = MainScene.ranking(rankingVM).viewController()
        
        let timelineVM = TimelineVM(user: self.user)
        let timelineVC = MainScene.timeline(timelineVM).viewController()
        
        
        self.viewControllers = [timelineVC, ingredientsVC, rankingVC, rankingVC, rankingVC, rankingVC]
                
      
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
    
    
    func setViewControllers(row: Int) {
       

        pageVC?.setViewControllers([viewControllers[row]], direction: .forward, animated: true, completion: { [unowned self] isCompleted in
            
            if isCompleted {
                
                self.currentViewController = viewControllers[row]
                
                if let currentViewController = currentViewController as? RankingViewController {
                    
                    currentViewController.viewModel.delegate = self
                    
                }
                else if let currentViewController = currentViewController as? IngredientsViewController {
                    
                    currentViewController.viewModel.delegate = self
                    
                }
                else if let currentViewController = currentViewController as? TimelineViewController {
                    
                    currentViewController.viewModel.delegate = self
                    
                }
            }
            
        })
    }
    
 
}


extension DiscoveryPresenter: toRecipeDetailDelegate {
    
    func selectedRecipe(recipe: Recipe) {
        
        let vm = RecipeVM(sceneCoordinator: self.sceneCoordinator, user: self.user, recipe: recipe)
        let scene: Scene = .recipeScene(scene: .recipe(vm))
        
        self.sceneCoordinator.modalTransition(to: scene, type: .push)
        
    }
    
}
