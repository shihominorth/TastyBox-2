//
//  SelectedImageViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-14.
//

import UIKit
import RxSwift
import RxCocoa

class SelectedImageViewController: UIViewController, BindableType {
   

    typealias ViewModelType = SelectedImageVM
    var viewModel: SelectedImageVM!

    @IBOutlet weak var imgView: UIImageView!
    
    var stackView: UIStackView!
    var cutBtn: UIButton!
    
    var addBtn: UIBarButtonItem!
    var tapView: UIView!
    var tap: UITapGestureRecognizer!

    override func viewDidLoad() {
       
        super.viewDidLoad()

        imgView.contentMode = .scaleAspectFit
        
        tapView = UIView()
        tapView.backgroundColor = .clear
        tapView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tapView)
        
        NSLayoutConstraint.activate([
           
            tapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            
        ])
        
        tap = UITapGestureRecognizer()
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        cutBtn = UIButton()
        
        guard let cutImg = UIImage(systemName: "scissors") else { return }
        cutBtn.setBackgroundImage(cutImg, for: .normal)
        cutBtn.tintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
  
        stackView.addArrangedSubview(cutBtn)
        
        self.tapView.addGestureRecognizer(tap)
        self.tapView.addSubview(stackView)
        self.tapView.bringSubviewToFront(stackView)

        let widthConstraint = self.stackView.widthAnchor.constraint(equalTo: self.tapView.widthAnchor, multiplier: 0.1)
        let heightConstraint =  self.stackView.heightAnchor.constraint(equalTo: self.tapView.widthAnchor, multiplier: 0.1)
        let bottomConstraint = NSLayoutConstraint(item: stackView!, attribute: .bottom, relatedBy: .equal, toItem: self.tapView, attribute: .bottom, multiplier: 1.0, constant: -85.0)
        let rightConstraint = NSLayoutConstraint(item: stackView!, attribute: .right, relatedBy: .equal, toItem: self.tapView, attribute: .right, multiplier: 1.0, constant: -20.0)
        
        NSLayoutConstraint.activate([
            widthConstraint, heightConstraint, rightConstraint, bottomConstraint
        ])
        
        
        self.addBtn = UIBarButtonItem()
        self.addBtn.title = "Add"
        self.navigationItem.rightBarButtonItem = addBtn
        
        self.imgView.fetchImageAsset(self.viewModel.asset, targetSize: self.imgView.frame.size, completionHandler: nil)
        
        
    }
    

    
    func bindViewModel() {
        
        tap.rx.event
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.isHiddenSubject)
            .subscribe(onNext: { [unowned self] isTapViewHidden in
                
                self.viewModel.isHiddenSubject.onNext(!isTapViewHidden)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        self.viewModel.isHiddenSubject.bind(to: self.stackView.rx.isHidden).disposed(by: viewModel.disposeBag)
        
        addBtn.rx.tap
            .flatMapLatest { [unowned self] in
                self.viewModel.getImageData()
            }
            .compactMap { $0 }
            .subscribe(onNext: { [unowned self] data in
                
                self.viewModel.addImage(imgData: data)
                
            })
            .disposed(by: viewModel.disposeBag)
        
    }
    
    
}
