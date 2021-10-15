//
//  SideMenuTableViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-16.
//

import UIKit
import Firebase
import RxCocoa
import RxSwift


class SideMenuTableViewController: UITableViewController {
    
    override func viewDidLoad() {
      
        self.tableView.separatorColor = UIColor.clear
        self.tableView.allowsSelection = true
    
    }
    
}
