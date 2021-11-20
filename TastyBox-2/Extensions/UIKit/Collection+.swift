//
//  Collection+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-20.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}
