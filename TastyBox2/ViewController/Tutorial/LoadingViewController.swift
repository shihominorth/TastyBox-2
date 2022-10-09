//
//  LoadingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-17.
//

import UIKit
import Firebase

class LoadingViewController: UIViewController, BindableType {
   
    typealias ViewModelType = LoadingVM
    var viewModel: LoadingVM!

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.startAnimating()
        navigationController?.isNavigationBarHidden = true
        
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.goToNextVC()

    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false

    }
    
    
    func bindViewModel() {
        
        
        
    }
        

}
