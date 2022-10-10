//
//  MockDiscoveryViewModel.swift
//  TastyBox2Tests
//
//  Created by 北島　志帆美 on 2022-10-10.
//

import Foundation
import Firebase
import RxCocoa
import RxSwift
import XCTest
@testable import TastyBox2

class MockDiscoveryViewModel: ViewModelBase, DiscoveryViewModelLike {    
    weak var navigator: DiscoveryNavigatorLike?
    private let sceneCoodinator: SceneCoordinator
    
    var isMenuBarOpenedRelay: BehaviorRelay<Bool>
    var pages: [String]
    
    var setSideMenuTableViewToPresenterClosure: ((SideMenuTableViewController) -> Void)?
    var setPageviewControllerToPresenterClosure: ((UIPageViewController) -> Void)?
    var setDefaultViewControllersClosure: (() -> Void)?
    var toCreateRecipeVCClosure: (() -> Void)?
    var sideMenuTappedClosure: (() -> Void)?
    var setIsMenuBarOpenedRelayClosure: (() -> Observable<Bool>)?
    var selectPageTitleClosure: ((Int) -> Void)?
    
    init(sceneCoodinator: SceneCoordinator, pages: [String] = ["Subscribed Creator",  "Your Ingredients Recipe", "Most Popular"]) {
        let presenter = MockDiscoveryPresenter(sceneCoordinator: sceneCoodinator)
        
        self.sceneCoodinator = sceneCoodinator
        self.navigator = presenter
        self.isMenuBarOpenedRelay = BehaviorRelay<Bool>(value: false)
        
        self.pages = pages
    }
    
    func setSideMenuTableViewToPresenter(tableView: SideMenuTableViewController) {
        setSideMenuTableViewToPresenterClosure?(tableView)
    }
    
    func setPageviewControllerToPresenter(pageViewController: UIPageViewController) {
        setPageviewControllerToPresenterClosure?(pageViewController)
    }

    func setDefaultViewControllers() {
        setDefaultViewControllersClosure?()
    }

    func toCreateRecipeVC() {
        toCreateRecipeVCClosure?()
    }
    
    func sideMenuTapped() {
        sideMenuTappedClosure?()
    }
    
    func setIsMenuBarOpenedRelay() -> Observable<Bool> {
        setIsMenuBarOpenedRelayClosure?() ?? .empty()
    }
    
    func selectPageTitle(row: Int) {
        selectPageTitleClosure?(row)
    }
}

extension MockDiscoveryViewModel {
    func expectSetSideMenuTableViewToPresenter(expectTableView: SideMenuTableViewController) -> XCTestExpectation {
        let expectation = XCTestExpectation()
        
        setSideMenuTableViewToPresenterClosure = { tableView in
            XCTAssertEqual(expectTableView, tableView)
            expectation.fulfill()
        }
        
        return expectation
    }
    
    func expectSetPageviewControllerToPresenter(expectPageViewController: UIPageViewController) -> XCTestExpectation {
        let expectation = XCTestExpectation()
        
        setPageviewControllerToPresenterClosure = { pageViewController in
            XCTAssertEqual(expectPageViewController, pageViewController)
            expectation.fulfill()
        }
        
        return expectation
    }
    
    func expectSetDefaultViewControllersOnce() -> XCTestExpectation {
        let expectation = XCTestExpectation()
        
        setDefaultViewControllersClosure = {
            expectation.fulfill()
        }
        
        return expectation
    }
    
    func expectSideMenuTapped() -> XCTestExpectation {
        let expectation = XCTestExpectation()

        sideMenuTappedClosure = {
            expectation.fulfill()
        }
        
        return expectation
    }
    
    func expectSelectPageTitle(expectedRow: Int) -> XCTestExpectation {
        let expectation = XCTestExpectation()

        selectPageTitleClosure = { row in
            XCTAssertEqual(row, expectedRow)
            expectation.fulfill()
        }
        
        return expectation
    }
}
