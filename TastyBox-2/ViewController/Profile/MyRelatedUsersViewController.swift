//
//  MyFollowingFolloweredUsersViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-11.
//

import UIKit
import RxSwift
import RxCocoa

class MyRelatedUsersViewController: UIViewController, BindableType {
    
    typealias ViewModelType = MyRelatedUsersVM
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var viewModel: MyRelatedUsersVM!
    
    var pageVC: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        pageVC = self.children.first as? UIPageViewController
        
        
    }
    
    func bindViewModel() {
        
        viewModel.selectIndexSubject
            .take(1)
                .subscribe(onNext: { index in
                    
                    self.self.segmentControl.rx.selectedSegmentIndex.onNext(index)
                    self.setUpPageController(index: index)
                    
                })
                .disposed(by: viewModel.disposeBag)
        
        self.segmentControl.rx.selectedSegmentIndex
            .subscribe(onNext: { index in
                
                self.setUpPageController(index: index)
                
                self.viewModel.selectIndexSubject.onNext(index)
                
            })
            .disposed(by: viewModel.disposeBag)
      
        
    }
    
    func setUpPageController(index: Int) {
        
        if index == 0 {
            
            self.pageVC.setViewControllers([self.viewModel.presenter.followingsVC], direction: .forward, animated: true)
        }
        else if index == 1 {
            
            self.pageVC.setViewControllers([self.viewModel.presenter.followersVC], direction: .reverse, animated: true)
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
