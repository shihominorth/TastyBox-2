//
//  MainTabBarViewModel.swift
//  TastyBox2
//
//  Created by 北島　志帆美 on 2022-10-14.
//

import Foundation
import Firebase

protocol MainTabBarViewModelLike: AnyObject where Self: ViewModelBase {
    func initializeChildren()
}

class MainTabBarViewModel: ViewModelBase, MainTabBarViewModelLike {
    let sceneCoordinator: SceneCoordinator
    let user: Firebase.User
    
    init(sceneCoordinator: SceneCoordinator, user: Firebase.User) {
        self.sceneCoordinator = sceneCoordinator
        self.user = user
    }
    
    func initializeChildren() {
        let discoveryViewModel = DiscoveryViewModel(sceneCoodinator: self.sceneCoordinator, user: self.user)
        let discoveryScene: Scene = .discovery(scene: .discovery(discoveryViewModel))
        
        let selectDigittalViewModel = SelectDigitalContentsVM(sceneCoodinator: self.sceneCoordinator, user: self.user, kind: .recipeMain(.thumbnail), isEnableSelectOnlyOneDigitalContentType: true)
        let postScene: Scene = .digitalContentsPickerScene(scene: .selectDigitalContents(selectDigittalViewModel))
        
        let searchScene: Scene = .search(scene: .main)
        
        self.sceneCoordinator.initalizeMainTabBarControllerChildren(firstTabScene: discoveryScene, secondTabScene: postScene, thirdTabScene: searchScene)
    }
}
