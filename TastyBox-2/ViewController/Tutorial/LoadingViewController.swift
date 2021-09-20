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
        
        
        let currentVersion : String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        let versionOfLastRun: String? = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
//
//        if versionOfLastRun == nil {
//            // First start after installing the app
//            let vm = TutorialVM(sceneCoodinator: self.sceneCoodinator)
//            let vc = LoginScene.tutorial(vm).viewController()
//
//            self.sceneCoodinator.transition(to: vc, type: .root)
//
//        }
//        //        else if  !(versionOfLastRun?.isEqual(currentVersion))! {
//        //            // App is updated
//        //        }
//        else {
//        }
 
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        let sceneCoodinator = SceneCoordinator(window: window)
//       
//        let vm = LoadingVM(sceneCoodinator: sceneCoodinator)
//        let vc = LoadingScene.loading(vm).viewController()
//        sceneCoodinator.transition(to: vc, type: .root)
        
      
       
        UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
        UserDefaults.standard.synchronize()
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
