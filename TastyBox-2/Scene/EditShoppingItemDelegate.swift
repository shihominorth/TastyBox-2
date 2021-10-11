//
//  EditIngredientDelegate.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-09.
//

import Foundation
import RxSwift

protocol EditShoppingItemDelegate: AnyObject {
    func addItemToArray(item: ShoppingItem)
    func edittedItem(item: ShoppingItem)
}

protocol EditRefrigerator: AnyObject {
    func addItemToArray(item: RefrigeratorItem)
}
