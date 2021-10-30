//
//  Int+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-08-27.
//

import Foundation

extension String {
    func convertToInt() -> Int? {
        
        guard let result = Int(self) else { return  nil }
        return result
        
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}


extension Array {
    
    var exists: Bool {
        return !self.isEmpty
    }
}
