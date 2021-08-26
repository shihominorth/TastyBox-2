//
//  BindableType.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-26.
//

import Foundation
import UIKit
import RxSwift

protocol BindableType {
  associatedtype ViewModelType
  
  var viewModel: ViewModelType! { get set }

  func bindViewModel()
}

extension BindableType where Self: UIViewController {
  mutating func bindViewModel(to model: Self.ViewModelType) {
    viewModel = model
    loadViewIfNeeded()
    bindViewModel()
  }
}
