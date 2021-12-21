//
//  MyFollowingFolloweredUsersViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-11.
//

import UIKit

class MyRelatedUsersViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var pageVC: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pageVC = self.children.first as? UIPageViewController
        
        
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
