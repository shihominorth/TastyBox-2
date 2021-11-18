//
//  ReportAlertView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-17.
//

import UIKit
import RxSwift

enum ReportReason: String {
    case harrasmentAndCyberbullying = "Harrasment and Cyberbullying"
    case privacy = "Privacy"
    case impersonation = "Impersonation" //なりすまし
    case violent = "Viorent thereads"
    case childEndangerment = "Child Endangerment"
    case hateSpeech = "Hate Speech against a Protected Group"
    case spamAndScams = "Spam and Scams"
    case others = "Others"
}

class ReportAlertView: UIView {
    
    let tableView = UITableView()
    
    let reasons: [ReportReason] = [.harrasmentAndCyberbullying, .privacy, .impersonation, .violent, .childEndangerment, .hateSpeech, .spamAndScams, .others]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.inputView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setUpTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpTableView() {
        
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reportOption")
        
        tableView.setEditing(true, animated: false)
        
        self.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }

}

extension ReportAlertView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reportOption") {

            cell.textLabel?.text = reasons[indexPath.row].rawValue

        }
        
        return UITableViewCell()
    }
}


