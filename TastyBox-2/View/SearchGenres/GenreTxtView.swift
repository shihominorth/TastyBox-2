//
//  GenreTxtView.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-29.
//

import UIKit
import RxSwift
import RxCocoa

class GenreTxtView: UITextView {
    
    
    var placeHolder: String = "" {
        willSet {
            self.placeHolderLabel.text = newValue
            self.placeHolderLabel.sizeToFit()
        }
    }
    
    private lazy var placeHolderLabel: UILabel = {
        
        let label = UILabel()
        
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = self.font
        label.textColor = .gray
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        return label
    }()
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSLayoutConstraint.activate([
            placeHolderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            placeHolderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 7),
            placeHolderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            placeHolderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5)
        ])
        
        self.rx.text
            .subscribe(onNext: { text in
                
                let shouldHidden = self.placeHolder.isEmpty || !self.text.isEmpty
                self.placeHolderLabel.alpha = shouldHidden ? 0 : 1
                
            })
            .disposed(by: disposeBag)
        
    }
 
}
