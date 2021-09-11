//
//  Error+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-10.
//

import Foundation

extension Error {
    func convertToNSError() -> NSError {
        let err = self as NSError
        
        return err
    }
}
