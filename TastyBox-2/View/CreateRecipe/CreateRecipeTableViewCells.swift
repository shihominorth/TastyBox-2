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
    
    var tapped: Observable<Void>!
    let imgSubject = PublishSubject<Data>()
    
    var disposeBag = DisposeBag()
    
    
    lazy var loadingView: UIView = {
        
        let view = UIView()
//        view.alpha = 0.5
       
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        return view
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        
        let result = UIActivityIndicatorView()
        result.style = .medium
        result.translatesAutoresizingMaskIntoConstraints = false
        
        result.startAnimating()
        
        return result
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        disposeBag = DisposeBag()
        
        tapped = imgViewBtn.rx.tap
            .debounce(.microseconds(1000), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                
                setUploadingView()
                
            })
        
        imgSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] data in
                    
                
                if let image = UIImage(data: data) {
                    self.imgViewBtn.setBackgroundImage(image, for: .normal)
                        
                }
                    
                indicator.stopAnimating()
                loadingView.removeFromSuperview()
                    
            })
            .disposed(by: disposeBag)
                
                
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        txtView.isScrollEnabled = false
        
        setUploadingView()
        
    }
    
    fileprivate func setUploadingView() {
        
        imgViewBtn.addSubview(loadingView)
        loadingView.frame = imgViewBtn.frame
        
        loadingView.topAnchor.constraint(equalTo: imgViewBtn.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: imgViewBtn.bottomAnchor).isActive = true
        loadingView.leadingAnchor.constraint(equalTo: imgViewBtn.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: imgViewBtn.trailingAnchor).isActive = true
    
        
        loadingView.addSubview(indicator)
        
        indicator.center = loadingView.center
        indicator.widthAnchor.constraint(equalTo: loadingView.widthAnchor, multiplier: 0.6, constant: 0).isActive = true
        indicator.heightAnchor.constraint(equalTo: loadingView.widthAnchor, multiplier: 0.6, constant: 0).isActive = true
        
    }
}
