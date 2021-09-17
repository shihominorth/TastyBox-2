//
//  LoadingViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-17.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.startAnimating()
        navigationController?.isNavigationBarHidden = true
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false

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
