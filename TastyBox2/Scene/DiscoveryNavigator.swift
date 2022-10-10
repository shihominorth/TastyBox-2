//
//  DiscoveryPresenter.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-15.
//

import Firebase
import RxCocoa
import RxSwift
import UIKit

protocol DiscoveryNavigatorLike: AnyObject {
    var pageViewController: UIPageViewController? { get set }
    var sideMenuViewController: SideMenuTableViewController? { get set }
    
    func setDefaultViewController()
    func setViewControllers(row: Int)
}

class DiscoveryNavigator: NSObject, DiscoveryNavigatorLike {
    private var viewControllers: [UIViewController]
    private let sceneCoordinator: SceneCoordinator
    private let user: Firebase.User
    private var currentViewController: UIViewController?
    
    var pageViewController: UIPageViewController?
    var sideMenuViewController: SideMenuTableViewController?
    
    init(user: Firebase.User, sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
        self.user = user
        
        let ingredientsViewModel = IngredientsViewModel(user: self.user)
        let ingredientsViewController = MainScene.ingredients(ingredientsViewModel).viewController()
        
        let rankingViewModel = RankingViewModel(user: self.user)
        let rankingViewController = MainScene.ranking(rankingViewModel).viewController()
        
        let timelineViewModel = TimelineViewModel(user: self.user)
        let timelineViewController = MainScene.timeline(timelineViewModel).viewController()
        
        self.viewControllers = [timelineViewController, ingredientsViewController, rankingViewController]
        
        super.init()
    }
    
    func setDefaultViewController() {
        pageViewController?.setViewControllers([viewControllers[1]], direction: .forward, animated: true, completion: { [unowned self] isCompleted in
            
            if isCompleted {
                
                self.currentViewController = viewControllers[1]
                
                guard let ingredientVC = self.currentViewController as? IngredientsViewController else {
                    return
                }
                ingredientVC.viewModel.delegate = self
            }
        })
        
//        pageViewController?.delegate = self
        pageViewController?.dataSource = self
    }
    
    func setViewControllers(row: Int) {
        guard let currentViewController = currentViewController, let currentIndex = viewControllers.firstIndex(where: { String(describing: $0) == String(describing: currentViewController) }) else {
            return
        }
        
        let orientation: UIPageViewController.NavigationDirection = currentIndex < row ? .forward : .reverse
        
        pageViewController?.setViewControllers([viewControllers[row]], direction: orientation, animated: true, completion: { [unowned self] isCompleted in
            
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


extension DiscoveryNavigator: toRecipeDetailDelegate {
    func selectedRecipe(recipe: Recipe) {
        let vm = RecipeVM(sceneCoordinator: self.sceneCoordinator, user: self.user, recipe: recipe)
        let scene: Scene = .recipeScene(scene: .recipe(vm))
        
        self.sceneCoordinator.transition(to: scene, type: .push)
    }
}

extension DiscoveryNavigator: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(where: { String(describing: currentViewController) == String(describing: $0) }) else {
            return nil
        }

        if index - 1 >= 0 {
            return viewControllers[index - 1]
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentViewController = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(where: { String(describing: currentViewController) == String(describing: $0) }) else {
            return nil
        }
        if index + 1 < viewControllers.count {
            return viewControllers[index + 1]
        }

        return nil
    }
}
