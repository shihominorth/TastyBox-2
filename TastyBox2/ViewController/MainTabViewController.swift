//
//  MainTabViewController.swift
//  TastyBox2
//
//  Created by 北島　志帆美 on 2022-10-12.
//

import UIKit

class MainTabViewController: UITabBarController, BindableType {
    typealias ViewModelType = MainTabBarViewModelLike
    
    var viewModel: MainTabBarViewModelLike!

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().tintColor = .orange
        UITabBar.appearance().unselectedItemTintColor = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initialViewControllers()
    }
    
    func bindViewModel() {
        
    }
    
    
    func initialViewControllers() {
        viewModel.initializeChildren()
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
