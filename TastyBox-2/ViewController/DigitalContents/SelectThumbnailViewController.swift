//
//  SelectThumbnailViewController.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-17.
//

import UIKit
import RxSwift
import RxCocoa

class SelectThumbnailViewController: UIViewController, BindableType {
    
    typealias ViewModelType = SelectThumbnailVM
    var viewModel: SelectThumbnailVM!
 
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    var thumbnailImgView: UIImageView!
    var toCameraRollView: UIView!
    var borderView: UIView!
    var toCameraRollLbl: UILabel!
    var toCameraRollImgView: UIImageView!
    var editStackView: UIStackView!
    var selectBtn: UIButton!
    var tap: UITapGestureRecognizer!
    
    // init cause self.navigationController is nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thumbnailImgView = {

            let imgView = UIImageView()
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.contentMode = .scaleAspectFit
            
            return imgView

        }()
        
        toCameraRollView = {
            
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false

            return view

        }()
       

        toCameraRollLbl = {
            
            let lbl = UILabel()
            lbl.textColor = .brown
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = "Select from Cameara roll"
            lbl.accessibilityIdentifier = "to camera roll lbl"

            
            return lbl
        }()
        
        toCameraRollImgView = {
            
            let imgView = UIImageView()
            
            if let img = UIImage(systemName: "photo.on.rectangle.angled") {
                imgView.image = img
            }
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.accessibilityIdentifier = "to cameara roll img view"
            imgView.tintColor = .brown

            return imgView
            
        }()
        
        borderView = {
            
            let view = UIView()
            view.backgroundColor = .gray
            view.translatesAutoresizingMaskIntoConstraints = false
            view.accessibilityIdentifier = "border view"

            return view
            
        }()
        
        editStackView = {
           
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            
            return stackView
            
        }()
        
        selectBtn = {
           
            let btn = UIButton()
            btn.setTitle("Select", for: .normal)
            btn.layer.cornerRadius = 20
            btn.backgroundColor = .orange
            btn.tintColor = .white
            
            return btn
        }()
        
        tap = UITapGestureRecognizer()
        
        
        toCameraRollImgView.accessibilityIdentifier = "camera roll view"
        thumbnailImgView.accessibilityIdentifier = "thumbnail img view"
        
        self.view.addSubview(thumbnailImgView)
        self.view.addSubview(editStackView)
        self.view.addSubview(toCameraRollView)
        self.view.addSubview(borderView)
        
        self.editStackView.addArrangedSubview(selectBtn)
        
        self.toCameraRollView.addSubview(toCameraRollImgView)
        self.toCameraRollView.addSubview(toCameraRollLbl)
        
        NSLayoutConstraint.activate([
            
            thumbnailImgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            thumbnailImgView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            thumbnailImgView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9),
            thumbnailImgView.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.9)
            
        ])
        
        NSLayoutConstraint.activate([
            toCameraRollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            toCameraRollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            toCameraRollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            toCameraRollView.heightAnchor.constraint(equalToConstant: (self.view.frame.height * 0.15) + 1.0)
        ])
        
        NSLayoutConstraint.activate([
            
            editStackView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9),
            editStackView.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.05),
            editStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            editStackView.bottomAnchor.constraint(equalTo: self.toCameraRollView.topAnchor, constant: -10)
        
        ])
        
        NSLayoutConstraint.activate([
            
            borderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            borderView.topAnchor.constraint(equalTo: self.toCameraRollView.topAnchor),
            borderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1.0)
            
        ])
        
        self.view.bringSubviewToFront(borderView)
        
        NSLayoutConstraint.activate([
            
            toCameraRollImgView.leadingAnchor.constraint(equalTo: toCameraRollView.layoutMarginsGuide.leadingAnchor),
            toCameraRollImgView.centerYAnchor.constraint(equalTo: toCameraRollView.centerYAnchor),
            toCameraRollImgView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.1),
            toCameraRollImgView.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.1)
            
        ])
        
        NSLayoutConstraint.activate([
            
            toCameraRollLbl.leadingAnchor.constraint(equalTo: toCameraRollImgView.trailingAnchor, constant: 10),
            toCameraRollLbl.centerYAnchor.constraint(equalTo: toCameraRollView.centerYAnchor),
            toCameraRollLbl.widthAnchor.constraint(equalToConstant: toCameraRollLbl.intrinsicContentSize.width),
            toCameraRollLbl.heightAnchor.constraint(equalToConstant: toCameraRollLbl.intrinsicContentSize.height)
            
        ])
        
        self.view.backgroundColor = .white
        
        guard let img = UIImage(data: viewModel.imageData) else { return }
        thumbnailImgView.image = img
        
        toCameraRollView.addGestureRecognizer(tap)
        
    }
    
 
    
    func bindViewModel() {
        
        tap.rx.event
            .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
            .debug("tap tapped")
            .delay(.milliseconds(1500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                
                self.viewModel.selectThumbnail()
                
            })
            .disposed(by: viewModel.disposeBag)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
