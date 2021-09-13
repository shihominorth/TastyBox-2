//
//  RxGIDSignInDelegateProxy.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-29.
//

import GoogleSignIn
import RxSwift
import RxCocoa

//class RxGIDSignInDelegateProxy: DelegateProxy<GIDSignIn, GIDSignInDelegate>, GIDSignInDelegate  {
//    public weak private(set) var gidSignIn: GIDSignIn?
//    var signInSubject = PublishSubject<GIDGoogleUser>()
//
//    init(gidSignIn: ParentObject) {
//        self.gidSignIn = gidSignIn
//        super.init(parentObject: gidSignIn, delegateProxy: RxGIDSignInDelegateProxy.self)
//    }
//
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if let u = user {
//            signInSubject.on(.next(u))
//        } else if let e = error {
//            signInSubject.on(.error(e))
//        }
//        _forwardToDelegate?.sign(signIn, didSignInFor:user, withError: error)
//    }
//
//    deinit {
//        signInSubject.on(.completed)
//    }
//}
//
//extension RxGIDSignInDelegateProxy :DelegateProxyType {
//    static func registerKnownImplementations() {
//        register { RxGIDSignInDelegateProxy(gidSignIn: $0) }
//    }
//
//    static func currentDelegate(for object: GIDSignIn) -> GIDSignInDelegate? {
//        return object.delegate
//    }
//
//    static func setCurrentDelegate(_ delegate: GIDSignInDelegate?, to object: GIDSignIn) {
//        object.delegate = delegate
//    }
//}
//
//extension Reactive where Base: GIDSignIn {
//    public var delegate: DelegateProxy<GIDSignIn, GIDSignInDelegate> {
//        return self.gidSignInDelegate
//    }
//
//    var signIn: Observable<GIDGoogleUser> {
//        let proxy = self.gidSignInDelegate
//        proxy.signInSubject = PublishSubject<GIDGoogleUser>()
//        return proxy.signInSubject
//            .asObservable()
//            .do(onSubscribed: {
//                proxy.gidSignIn?.signIn()
//            })
//            .take(1)
//            .asObservable()
//    }
//}
