//
//  RxUIViewController+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-22.
//

import UIKit
import RxCocoa
import RxSwift

public extension Reactive where Base: UIViewController {
    
    var viewWillDisappear: ControlEvent<Bool> {
       let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
       return ControlEvent(events: source)
     }
}
