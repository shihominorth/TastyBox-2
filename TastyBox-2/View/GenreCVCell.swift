//
//  GenreCVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-23.
//

import UIKit

final class GenreCVCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    var isSelectedGenre = false
    
    override var reuseIdentifier: String? {
        return "genreCell"
    }
      
      override init(frame: CGRect) {
          super.init(frame: frame)
          
          self.contentView.layer.cornerRadius = 2.0
          self.contentView.layer.masksToBounds = true
      }
      
      override func awakeFromNib() {
          super.awakeFromNib()
          // initialize what is needed
          
          
          self.contentView.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
          self.contentView.layer.borderWidth = 2
          self.contentView.layer.cornerRadius = 10.0
          self.contentView.layer.masksToBounds = true
          
          self.titleLbl.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
      
        
      }
      
      required init?(coder: NSCoder) {
          super.init(coder: coder)
          
      }
    
    func configure() {
        
        if self.isSelectedGenre {
            
            self.contentView.layer.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            self.titleLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        else {
            
            self.contentView.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.titleLbl.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        }
    }
      
      func setIsSelectedGenre() {
          
          self.isSelectedGenre = !self.isSelectedGenre
          
          if self.isSelectedGenre {
              self.contentView.layer.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
              self.titleLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
          }
          else {
              
              self.contentView.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
              self.titleLbl.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
          }
          
       
          
      }
}
