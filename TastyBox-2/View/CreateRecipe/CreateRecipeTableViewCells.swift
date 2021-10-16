//
//  CreateRecipeTableViewCells.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import UIKit
import RxSwift
import RxCocoa

class EditTitleRecipeTVCell: UITableViewCell {
    
    @IBOutlet weak var txtField: UITextField!
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

class EditTimeNSearvingTVCell: UITableViewCell {
    
    @IBOutlet weak var timeTxtField: UITextField!
    @IBOutlet weak var servingTxtField: UITextField!
   
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

class EditIngredientsHeaderCell: UITableViewCell {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var editbtn: UIButton!
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

class EditIngredientsTVCell: UITableViewCell {
   
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var amountTxtField: UITextField!
    
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

class EditInstructionHeaderTVCell: UITableViewCell {
   
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
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

class EditInstructionTVCell: UITableViewCell {
   
    @IBOutlet weak var stepNumLbl: UILabel!
    
    @IBOutlet weak var imgViewBtn: UIButton!
    @IBOutlet weak var txtView: UITextView!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        txtView.isScrollEnabled = false
        
    }
}
