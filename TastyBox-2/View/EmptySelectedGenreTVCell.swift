//
//  EmptySelectedGenreTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-23.
//

import UIKit

class EmptySelectedGenreTVCell: UITableViewCell {
    
    let addBtn = UIButton()
    
    override var reuseIdentifier: String? {
        return "EmptyGenres"
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure()
    }

    func configure() {

        addBtn.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width * 0.7, height: 30)
        addBtn.setTitle("Add Genres", for: .normal)
        
        self.contentView.addSubview(addBtn)
        
        addBtn.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        addBtn.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        addBtn.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.7).isActive = true
        addBtn.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.7).isActive = true
    }
}
