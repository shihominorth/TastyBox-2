//
//  MockDiscoveryPresenter.swift
//  TastyBox2Tests
//
//  Created by 北島　志帆美 on 2022-10-10.
//

import UIKit
@testable import TastyBox2

class MockDiscoveryPresenter: DiscoveryNavigatorLike {
    private var viewControllers: [UIViewController]
    private let sceneCoordinator: SceneCoordinator
    
    var pageViewController: UIPageViewController?
    var sideMenuViewController: SideMenuTableViewController?
    
    var setDefaultViewControllerClosure: (() -> Void)?
    var setViewControllersClosure: ((Int) -> Void)?
    
    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
        self.viewControllers = [] //後でモックを入れる
    }
    
    func setDefaultViewController() {
        setDefaultViewControllerClosure?()
    }
    
    func setViewControllers(row: Int) {
        setViewControllersClosure?(row)
    }
}
