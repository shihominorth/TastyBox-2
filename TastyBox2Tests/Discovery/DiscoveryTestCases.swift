//
//  DiscoveryTestCases.swift
//  TastyBox2Tests
//
//  Created by 北島　志帆美 on 2022-10-10.
//

import Firebase
import XCTest
@testable import TastyBox2

final class DiscoveryTestCases: XCTestCase {
    enum TestError: Error {
        case unwrappedFail
    }
    
    private var testTarget: DiscoveryViewController!
    private var mockViewModel: MockDiscoveryViewModel!
 
    override func setUpWithError() throws {
        let window = UIWindow()
        let sceneCoodinator = SceneCoordinator(window: window)
        mockViewModel = MockDiscoveryViewModel(sceneCoodinator: sceneCoodinator)
        
        guard let viewController: DiscoveryViewController = Scene.discovery(scene: .main(mockViewModel)).viewController() as? DiscoveryViewController else {
            throw TestError.unwrappedFail
        }
        
        testTarget = viewController
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPrepare() throws {
        XCTContext.runActivity(named: "side menu table viewがちゃんとview modelに伝わるか") { _ in
            let sideTableViewcontroller = SideMenuTableViewController()
            let segue = UIStoryboardSegue(identifier: "toSideMenu", source: testTarget, destination: sideTableViewcontroller)
            
            
            let expectation = mockViewModel.expectSetSideMenuTableViewToPresenter(expectTableView: sideTableViewcontroller)
            
            testTarget.prepare(for: segue, sender: nil)
            
            wait(for: [expectation], timeout: .leastNormalMagnitude)
        }
        
        XCTContext.runActivity(named: "page controllerがちゃんとview modelに伝わるか") { _ in
            let pageViewController = UIPageViewController()
            let segue = UIStoryboardSegue(identifier: "showPageVC", source: testTarget, destination: pageViewController)
            
            
            let expectation = mockViewModel.expectSetPageviewControllerToPresenter(expectPageViewController: pageViewController)
            
            testTarget.prepare(for: segue, sender: nil)
            
            wait(for: [expectation], timeout: .leastNormalMagnitude)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
