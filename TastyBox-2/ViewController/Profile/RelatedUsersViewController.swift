//
//  RelatedUsersViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-23.
//

import UIKit

class RelatedUsersViewController: UIViewController, BindableType {
    
    typealias ViewModelType = RelatedUsersVM
    

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var viewModel: RelatedUsersVM!
    var pageVC: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageVC = self.children.first as? UIPageViewController

    }
    
    func bindViewModel() {
        
        
        
    }
    
    

    func setUpPageController(index: Int) {
        
        if index == 0 {
            
            self.pageVC.setViewControllers([self.viewModel.presenter.followingsVC], direction: .forward, animated: true)
        }
        else if index == 1 {
            
            self.pageVC.setViewControllers([self.viewModel.presenter.followedsVC], direction: .forward, animated: true)
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
