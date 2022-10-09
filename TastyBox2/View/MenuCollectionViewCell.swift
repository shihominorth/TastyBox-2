//
//  MenuCollectionViewCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2022-10-06.
//
import RxCocoa
import RxSwift
import UIKit

final class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var MenuLabel: UILabel!
    let isSelectedBehavoirSubject = BehaviorRelay(value: false)
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disposeBag = DisposeBag()
        
        isSelectedBehavoirSubject
            .subscribe(onNext: { isSelectedCell in
                self.focusCell(active: isSelectedCell)
            })
            .disposed(by: disposeBag)
    }
    
    func focusCell(active: Bool) {
        let color = active ? #colorLiteral(red: 1, green: 0.9882352941, blue: 0.6549019608, alpha: 1) : #colorLiteral(red: 0.9882352941, green: 0.8862745098, blue: 0.4549019608, alpha: 1)
        self.contentView.backgroundColor = color
        let labelColor = active ? #colorLiteral(red: 0.6745098039, green: 0.5568627451, blue: 0.4078431373, alpha: 1) : #colorLiteral(red: 0.9960784314, green: 0.6509803922, blue: 0.1921568627, alpha: 1)
        MenuLabel.textColor = labelColor
    }
}
