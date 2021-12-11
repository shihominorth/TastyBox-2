//
//  Segues.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-11.
//

import Foundation
import SwiftMessages

class CenterCardSegue: SwiftMessagesSegue {
    
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
        dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
        messageView.configureNoDropShadow()
        
    }
}
