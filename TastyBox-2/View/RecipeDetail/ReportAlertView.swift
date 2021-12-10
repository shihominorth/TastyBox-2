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
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //inputview
       
        setUpTableView()

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    
    func setUpTableView() {

        let defaultCellheight = 44.0
        let tableViewHeight = defaultCellheight * CGFloat(reasons.count + 1) + 1.0

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReportAlertViewCell.self, forCellReuseIdentifier: "reportOption")
        tableView.register(ReportAlertFooterView.self, forHeaderFooterViewReuseIdentifier: "reportFooterView")

//        tableView.tableFooterView = UIView()


        self.addSubview(tableView)

        tableView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: tableViewHeight).isActive = true
        tableView.widthAnchor.constraint(equalTo: self.heightAnchor, constant: 400).isActive = true
        tableView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }
//
//
//    fileprivate func setUpStackView() {
        
    
//
//        stackView.axis = .horizontal
//
//        stackView.addArrangedSubview(cancelBtn)
//        stackView.addArrangedSubview(reportBtn)
//
//        self.addSubview(stackView)
//
//        stackView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 10).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
//    }
    

}

extension ReportAlertView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reportOption") as? ReportAlertViewCell {

            
            cell.titleLbl.text = reasons[indexPath.row].rawValue
            
            return cell

        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reportFooterView") as? ReportAlertFooterView {

            let reportBtn = UIButton()
            let cancelBtn = UIButton()
            
            let stackView = UIStackView()
            
            reportBtn.accessibilityIdentifier = "report"
            cancelBtn.accessibilityIdentifier = "cancel"
            stackView.accessibilityIdentifier = "stackview"
            
            reportBtn.setTitleColor(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), for: .normal)
            cancelBtn.setTitleColor(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), for: .normal)
            
            reportBtn.setTitle("Report", for: .normal)
            cancelBtn.setTitle("Cancel", for: .normal)

            reportBtn.tag = 1
            cancelBtn.tag = 2
            
            stackView.spacing = 5
            stackView.axis = .horizontal

            stackView.translatesAutoresizingMaskIntoConstraints = false
            reportBtn.translatesAutoresizingMaskIntoConstraints = false
            cancelBtn.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(reportBtn)
            stackView.addArrangedSubview(cancelBtn)
            
            footerView.addSubview(stackView)
            
            let trailingConstraint = NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: footerView, attribute: .trailingMargin, multiplier: 1.0, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: footerView, attribute: .bottom, multiplier: 1.0, constant: 0)
            
            NSLayoutConstraint.activate([
                trailingConstraint, bottomConstraint
            ])
            
//
//            if let reportBtn = stackView.arrangedSubviews.first(where: { $0.tag == 1 }) as? UIButton {
//
//                reportBtn.heightAnchor.constraint(equalTo: footerView.heightAnchor, constant: reportBtn.frame.height).isActive = true
//                reportBtn.widthAnchor.constraint(equalTo: footerView.widthAnchor, constant: reportBtn.frame.width).isActive = true
//            }
//
//            if let cancelBtn = stackView.arrangedSubviews.first(where: { $0.tag == 2 }) as? UIButton {
//
//                cancelBtn.heightAnchor.constraint(equalTo: footerView.heightAnchor, constant: cancelBtn.frame.height).isActive = true
//                cancelBtn.widthAnchor.constraint(equalTo: footerView.widthAnchor, constant: cancelBtn.frame.width).isActive = true
//
//
//            }
            
            
//            NSLayoutConstraint.activate([
//
//                stackView.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
//                stackView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
//                stackView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
//                stackView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
//
//            ])

            
            
  

            return footerView
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 45.0
        }
        
        return 0.0
    }
}




class ReportAlertViewCell: UITableViewCell {
    
    let titleLbl = UILabel()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        titleLbl.accessibilityIdentifier = "title label"
        
        self.contentView.addSubview(self.titleLbl)
        
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.titleLbl.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            self.titleLbl.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
            self.titleLbl.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        
        ])
    }
    
}

class ReportAlertFooterView: UITableViewHeaderFooterView {
   
    
    override func awakeFromNib() {
        
       
        
       
    }
    
}
