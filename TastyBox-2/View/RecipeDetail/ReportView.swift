//
//  ReportView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-18.
//

import UIKit

class ReportView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.fromNib()
    }
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
