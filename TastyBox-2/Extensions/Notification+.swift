//
//  Notification+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-23.
//

import Foundation
import SCLAlertView

extension Notification {
    
    func showErrNotification() {
        
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
