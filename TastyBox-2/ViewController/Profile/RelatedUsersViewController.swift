//
//  RelatedUsersViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-23.
//

import UIKit
import RxSwift

class RelatedUsersViewController: UIViewController, BindableType {
    
    typealias ViewModelType = RelatedUsersVM
    

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var viewModel: RelatedUsersVM!
    var pageVC: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageVC = self.children.first as? UIPageViewController

        pageVC.delegate = self
        pageVC.dataSource = self

    }
    
    func bindViewModel() {
        
        
        viewModel.selectIndexSubject
            .take(1)
            .subscribe(onNext: { [unowned self] index in
                
                self.segmentControl.selectedSegmentIndex = index
                self.setUpPageController(index: index)
                
            })
            .disposed(by: viewModel.disposeBag)
 
        
        segmentControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] index in
                
                if let currentViewController = self.pageVC.viewControllers?.first {
                    
                    switch index {
                    case 0:
                        
                        guard currentViewController is FollowingsViewController else {
                            
                            self.setUpPageController(index: index)
                            
                            return
                            
                        }
                        
                    case 1:
                        
                        guard currentViewController is FollowersViewController else {
                            
                            self.setUpPageController(index: index)
                            
                            return
                        }
                        
                    default:
                        break
                    }
                    
                }


            })
            .disposed(by: viewModel.disposeBag)
        
    }
    
    

    func setUpPageController(index: Int) {
        
        if index == 0 {
            
            self.pageVC.setViewControllers([self.viewModel.presenter.followingsVC], direction: .reverse, animated: true)
        }
        else if index == 1 {
            
            self.pageVC.setViewControllers([self.viewModel.presenter.followersVC], direction: .forward, animated: true)
        }
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension RelatedUsersViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return 2
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController is FollowersViewController {
                                    
            return self.viewModel.presenter.followingsVC
        }
        
    
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        
        if viewController is FollowingsViewController {
                        
            return self.viewModel.presenter.followersVC
        }
        
        return nil
    }
   
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {


        if finished {

            if let currentViewController = self.pageVC.viewControllers?.first {
                
                if currentViewController is FollowingsViewController {

                    self.segmentControl.selectedSegmentIndex = 0

                }
                else if currentViewController is FollowersViewController {
                    
                    self.segmentControl.selectedSegmentIndex = 1
                    
                }
            }

        }
    }
    
}
