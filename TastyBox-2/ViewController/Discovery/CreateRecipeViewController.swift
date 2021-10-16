//
//  CreateRecipeViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import UIKit

class CreateRecipeViewController: UIViewController, BindableType {
 
   
    typealias ViewModelType = CreateRecipeVM
    
    var viewModel: CreateRecipeVM!
  
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func bindViewModel() {
        
    }

}

extension CreateRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

