//
//  UIView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-18.
//

import UIKit

extension UIView {

    @discardableResult   // 1
    func fromNib<T : UIView>() -> T? {   // 2
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {    // 3
            // xib not loaded, or its top view is of the wrong type
            return nil
        }

        self.addSubview(contentView)     // 4
        contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
//        contentView.layoutAttachAll(to: self)   // 6
        return contentView   // 7
    }
}
