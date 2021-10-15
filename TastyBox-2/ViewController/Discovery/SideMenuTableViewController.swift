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
//        self.tableView.delegate = self
//        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
    }
  
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name: NSNotification.Name("ShowProfile"), object: nil)
        case 1:
            NotificationCenter.default.post(name: NSNotification.Name("ShowSetting"), object: nil)
        case 2:
            NotificationCenter.default.post(name: NSNotification.Name("ShowRefrigerator"), object: nil)
            
            // adding refrigerator and shopping list cells in menu bar.
        case 3:
            NotificationCenter.default.post(name: NSNotification.Name("ShowShoppingList"), object: nil)
        case 4:
            NotificationCenter.default.post(name: NSNotification.Name("ShowContact"), object: nil)
            
        case 5:
            NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
        case 6:
            NotificationCenter.default.post(name: NSNotification.Name("ShowLogout"), object: nil)
        default: break
        }
    }
    
    
}
