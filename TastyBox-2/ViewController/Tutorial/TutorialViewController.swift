//
//  TutorialViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-17.
//

import UIKit

class TutorialViewController: UIViewController, BindableType {
   
    typealias ViewModelType = TutorialVM
    var viewModel: TutorialVM!

//    for tutorials creation
//    https://techlife.cookpad.com/entry/2019/08/16/090000
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false

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
