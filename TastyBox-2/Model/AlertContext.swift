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
    
    func generateAlert() {
        
        let alertView = SCLAlertView()
//        let context = SCLAlertView().showTitle(
//            "Congratulations", // Title of view
//            subTitle: "Operation successfully completed.",
//            timeout: .none, // String of view
//            completeText: "Done", // Optional button value, default: ""
//            style: .success, // Styles - see below.
//            colorStyle: 0xA429FF,
//            colorTextButton: 0xFFFFFF
//        )
        
        alertView.showError(self.reason, subTitle: self.solution)
    }
}
