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
            .map { $0.row }
            .bind(to: viewModel.selectedSubject)
            .disposed(by: viewModel.disposeBag)

    }
    
    func setUpTableView() {

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ReportAlertFooterView.self, forHeaderFooterViewReuseIdentifier: "reportFooterView")

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

class ReportAlertFooterView: UITableViewHeaderFooterView {
   
    
    override func awakeFromNib() {
        
       
        
       
    }
    
}
