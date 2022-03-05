//
//  ReportViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-11.
//

import UIKit
import RxSwift
import RxCocoa

class ReportViewController: UIViewController, BindableType {
    
    typealias ViewModelType = ReportVM
    var viewModel: ReportVM!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
    }
    
    func bindViewModel() {
        
        tableView.rx.itemSelected
            .do(onNext: { [unowned self] indexPath in
                
                self.tableView.deselectRow(at: indexPath, animated: true)
                
            })
                .map { $0.row }
                .bind(to: viewModel.selectedSubject)
                .disposed(by: viewModel.disposeBag)
        
        tableView.separatorStyle = .none
        
    }
    
    func setUpTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ReportAlertFooterView.self, forHeaderFooterViewReuseIdentifier: "reportFooterView")
        
        tableView.register(ReportAlertHeaderView.self, forHeaderFooterViewReuseIdentifier: "reportHeaderView")
        

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
    }
    
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reportOption") as? ReportAlertViewTVCell {
            
            self.viewModel.selectedSubject
                .map { $0 == indexPath.row }
                .subscribe(onNext: { isCellSelected in
                    
                    cell.selectedImgView.image = isCellSelected ? UIImage(systemName: "circle.inset.filled") : UIImage(systemName: "circle")
                    
                })
                .disposed(by: cell.disposeBag)
            
            cell.titleLbl.text = viewModel.reasons[indexPath.row].rawValue
            
            
            return cell
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reportHeaderView") as? ReportAlertHeaderView {
            
            
            switch viewModel.kind {
            case .recipe:
                headerView.titleLbl.text = "Report this recipe"
                
            case .comment:
                headerView.titleLbl.text = "Report this comment"
                
            case .post:
                headerView.titleLbl.text = "Report this post"
                
            }
            
            headerView.titleLbl.accessibilityIdentifier = "label"
            headerView.titleLbl.textColor = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
            
            headerView.titleLbl.translatesAutoresizingMaskIntoConstraints = false
            
            headerView.addSubview(headerView.titleLbl)
            
            NSLayoutConstraint.activate([
                
                headerView.titleLbl.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor),
                headerView.titleLbl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
                
            ])
            
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reportFooterView") as? ReportAlertFooterView {
            
            footerView.reportBtn.accessibilityIdentifier = "report"
            footerView.cancelBtn.accessibilityIdentifier = "cancel"
            footerView.stackView.accessibilityIdentifier = "stackview"
            
            footerView.reportBtn.setTitleColor(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), for: .normal)
            footerView.cancelBtn.setTitleColor(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), for: .normal)
            
            footerView.reportBtn.setTitle("Report", for: .normal)
            footerView.cancelBtn.setTitle("Cancel", for: .normal)
            
            footerView.reportBtn.tag = 1
            footerView.cancelBtn.tag = 2
            
            footerView.stackView.spacing = 10
            footerView.stackView.axis = .horizontal
            
            footerView.stackView.translatesAutoresizingMaskIntoConstraints = false
            footerView.reportBtn.translatesAutoresizingMaskIntoConstraints = false
            footerView.cancelBtn.translatesAutoresizingMaskIntoConstraints = false
            
            footerView.stackView.addArrangedSubview(footerView.cancelBtn)
            footerView.stackView.addArrangedSubview(footerView.reportBtn)
            
            footerView.addSubview(footerView.stackView)
            
            let trailingConstraint = NSLayoutConstraint(item: footerView.stackView, attribute: .trailing, relatedBy: .equal, toItem: footerView, attribute: .trailingMargin, multiplier: 1.0, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: footerView.stackView, attribute: .bottom, relatedBy: .equal, toItem: footerView, attribute: .bottom, multiplier: 1.0, constant: 0)
            
            NSLayoutConstraint.activate([
                trailingConstraint, bottomConstraint
            ])
            
            footerView.reportBtn.rx.tap
                .debug("tapped")
                .withLatestFrom(viewModel.selectedSubject)
                .do(onNext: { row in
                    print(row)
                })
                .flatMapLatest { [unowned self] row in
                    self.viewModel.report(row: row)
                }
                .subscribe(onNext: { [unowned self] isCompleted in
                    
                    self.dismiss(animated: true) {
                        self.viewModel.userDismissed()
                    }
  
                })
                .disposed(by: viewModel.disposeBag)
            
            footerView.cancelBtn.rx.tap
                .subscribe(onNext: { [unowned self] in
                    
                    self.dismiss(animated: true) {
                        self.viewModel.userDismissed()
                    }
                    
                })
                .disposed(by: viewModel.disposeBag)
            
            return footerView
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 45.0
        }
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 45.0
        }
        
        return 0.0
    }
}

class ReportAlertHeaderView: UITableViewHeaderFooterView {
    
    let titleLbl = UILabel()
    
}

class ReportAlertFooterView: UITableViewHeaderFooterView {
    
    let reportBtn = UIButton()
    let cancelBtn = UIButton()
    
    let stackView = UIStackView()
    
    override func awakeFromNib() {
        
        
        
        
    }
    
}
