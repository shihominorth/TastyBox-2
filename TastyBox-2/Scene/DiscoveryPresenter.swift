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
    private let sceneCoordinator: SceneCoordinator
    private let user: Firebase.User
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
        
        
        self.viewControllers = [timelineVC, ingredientsVC, rankingVC]
                
        super.init()
        
    
        
    }
    
    func setDefaultViewController() {
       
        pageVC?.setViewControllers([viewControllers[1]], direction: .forward, animated: true, completion: { [unowned self] isCompleted in
            
            if isCompleted {
                
                self.currentViewController = viewControllers[1]
                
                if let ingredientVC = self.currentViewController as? IngredientsViewController {
                    
                    ingredientVC.viewModel.delegate = self

                }
            }
            
        })
        
        pageVC?.delegate = self
        pageVC?.dataSource = self
        
    }
    
    
    func setViewControllers(row: Int) {
       

        guard let currentViewController = currentViewController, let currentIndex = viewControllers.firstIndex(where: { String(describing: $0) == String(describing: currentViewController) }) else {
            return
        }

        let orientation: UIPageViewController.NavigationDirection = currentIndex < row ? .forward : .reverse
        
        pageVC?.setViewControllers([viewControllers[row]], direction: orientation, animated: true, completion: { [unowned self] isCompleted in
            
            if isCompleted {

                
                if let currentViewController = viewControllers[row] as? RankingViewController {
                    
                    currentViewController.viewModel.delegate = self
                    
                }
                else if let currentViewController = viewControllers[row] as? IngredientsViewController {
                    
                    currentViewController.viewModel.delegate = self
                    
                }
                else if let currentViewController = viewControllers[row] as? TimelineViewController {
                    
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
        
        self.sceneCoordinator.transition(to: scene, type: .push)
        
    }
    
}

extension DiscoveryPresenter: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentViewController = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(where: { String(describing: currentViewController) == String(describing: $0) }) {
            
            
            if index - 1 >= 0 {
            
                return viewControllers[index - 1]
            
            }
    
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
       
        if let currentViewController = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(where: { String(describing: currentViewController) == String(describing: $0) }) {

            
            if index + 1 < viewControllers.count {
                
                return viewControllers[index + 1]
            }
        }
        
        return nil
    }
}
