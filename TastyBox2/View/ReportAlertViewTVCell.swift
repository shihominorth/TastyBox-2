//
//  ReportAlertViewTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-11.
//

import UIKit
import RxSwift

final class ReportAlertViewTVCell: UITableViewCell {

    @IBOutlet weak var selectedImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
