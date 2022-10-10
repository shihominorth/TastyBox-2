//
//  Error.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-11.
//

import Foundation
import SCLAlertView

struct Notification {
    var reason: String
    var solution: String
    var isReportRequired = false
}


extension Notification {
    
    func generateErrAlert() {
                
        SCLAlertView().showTitle(
            self.reason, // Title of view
            subTitle: self.solution,
            timeout: .none, // String of view
            completeText: "Done", // Optional button value, default: ""
            style: .error, // Styles - see below.
            colorStyle: 0xA429FF,
            colorTextButton: 0xFFFFFF
        )
    }
}
