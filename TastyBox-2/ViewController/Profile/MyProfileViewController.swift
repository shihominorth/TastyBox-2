//
//  MyPageViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-04.
//

import UIKit

class MyProfileViewController: UIViewController, BindableType {
    
    typealias ViewModelType = MyProfileVM
    var viewModel: MyProfileVM!


    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        
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
