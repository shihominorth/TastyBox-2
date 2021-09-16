//
//  SceneDelegate.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-25.
//

import FBSDKLoginKit
import Firebase
import RxSwift
import SCLAlertView
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        //userActivityプロパティからリンクURLを取得
        guard let url = userActivity.webpageURL else { return }
        let link = url.absoluteString
        
        if Auth.auth().isSignIn(withEmailLink: link) {
            //ローカルに保存していたメールアドレスを取得
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                print("メールアドレスが存在しません")
                return
            }
            
            
            
            let sceneCoordinator = SceneCoordinator(window: window!)
            
            let viewModel = SetPasswordVM(email: email, sceneCoordinator: sceneCoordinator)
            
            let vc = LoginScene.setPassword(viewModel).viewController()
            
            sceneCoordinator.transition(to: vc, type: .root)
            
            //ログイン処理
            //            Auth.auth().signIn(withEmail: email, link: link) { (auth, err) in
            //                if let err = err {
            //                    print("ログイン失敗")
            //                    print(err)
            //                    return
            //                }
            //                print("ログイン成功")
            
            //ログイン成功時の処理 (例えば、今回は画面切り替えなどの処理)
            //                guard let scene = (scene as? UIWindowScene) else { return }
            //                let window = UIWindow(windowScene: scene)
            //                let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            //                let didSignInVC = storyboard.instantiateViewController(withIdentifier: "setPassword")
            //                window.rootViewController = didSignInVC
            //                self.window = window
            //                window.makeKeyAndVisible()
        }
        //        }
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        let currentVersion : String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        let versionOfLastRun: String? = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
        
        if versionOfLastRun == nil {
            // First start after installing the app
            
            // start tutorial
        } else if  !(versionOfLastRun?.isEqual(currentVersion))! {
            // App is updated
        }
        
        UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
        UserDefaults.standard.synchronize()
        
        let sceneCoodinator = SceneCoordinator(window: window!)
        
        if let user = Auth.auth().currentUser {
            
            let _ = isRegisteredMyInfo(user: user).subscribe(onSuccess: { isFirst in
                
                if isFirst {
                    
                    let vm = RegisterMyInfoProfileVM(sceneCoodinator: sceneCoodinator, user: user)
                    let vc = LoginScene.profileRegister(vm).viewController()
                    sceneCoodinator.transition(to: vc, type: .root)
                    
                } else {
                    let viewModel = DiscoveryVM(sceneCoodinator: sceneCoodinator, user: user)
                    let vc = MainScene.discovery(viewModel).viewController()
                    sceneCoodinator.transition(to: vc, type: .root)
                }
                
            }, onFailure: { err in
                
                print(err as NSError)
                
                guard let reason = err.handleAuthenticationError() else { return }
                SCLAlertView().showTitle(
                    reason.reason, // Title of view
                    subTitle: reason.solution,
                    timeout: .none, // String of view
                    completeText: "Done", // Optional button value, default: ""
                    style: .error, // Styles - see below.
                    colorStyle: 0xA429FF,
                    colorTextButton: 0xFFFFFF
                )
            })
            
            
        }
        else {
            
            let viewModel = LoginMainVM(sceneCoodinator: sceneCoodinator)
            
            let firstScene = LoginScene.main(viewModel).viewController()
            sceneCoodinator.transition(to: firstScene, type: .root)
            
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

extension SceneDelegate {
    
    func isRegisteredMyInfo(user: FirebaseAuth.User) -> Single<Bool> {
        
        return Single.create { single in
            
            Firestore.firestore().collection("users").document(user.uid).addSnapshotListener { data, err in
                
                if let err = err {
                    single(.failure(err))
                } else {
                    
                    guard let data = data else { return }
                    guard let isFirst = data.get("isFirst") as? Bool else {
                        
                        single(.success(true))
                        return
                        
                    }
                    
                    single(.success(isFirst))
                    
                }
                
            }
            
            return Disposables.create()
        }
    }
}
