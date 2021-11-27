//
//  FirstTimeUserProfileViewController.swift
//  Recipe-CICCC
//
//  Created by Argus Chen on 2020-02-24.
//  Copyright © 2020 Argus Chen. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import Photos
import RSKImageCropper
import RxSwift
import RxCocoa
import SwiftUI

class RegisterMyInfoProfileTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, BindableType {
    
    var viewModel: RegisterMyInfoProfileVM!
    
    typealias ViewModelType = RegisterMyInfoProfileVM
    
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var familySizeTextField: UITextField!
    
    @IBOutlet weak var cuisineTypeTextField: UITextField!
    
    @IBOutlet weak var userImageButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    
    
    var familyPicker = UIPickerView()
    
    var cuisinePicker = UIPickerView()
    
    var imageCropVC : RSKImageCropViewController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpTxtFields()
        
        //        setUpKeyboard()
        
        PickerColor()
        
        userImageButton.imageView?.contentMode = .scaleAspectFit
        userImageButton.layer.cornerRadius = 0.5 * userImageButton.bounds.size.width
        userImageButton.clipsToBounds = true
        
    }
    
    
    
    func bindViewModel() {
        
        viewModel.isEnableDone.bind(to: doneButton.rx.isEnabled).disposed(by: viewModel.disposeBag)
        
        userNameTextField.rx.text.orEmpty.bind(to: viewModel.userName).disposed(by: viewModel.disposeBag)
        emailTextField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: viewModel.disposeBag)
        familySizeTextField.rx.text.orEmpty.bind(to: viewModel.familySize).disposed(by: viewModel.disposeBag)
        cuisineTypeTextField.rx.text.orEmpty.bind(to: viewModel.cuisineType).disposed(by: viewModel.disposeBag)
        
        self.viewModel.getUserImage()
            .subscribe(onNext: { data in
                
                self.viewModel.photoPickerSubject
                    .bind(to: self.viewModel.userImage)
                    .disposed(by: self.viewModel.disposeBag)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        self.userImageButton.rx.tap
            .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                
                self.tableView.endEditing(true)
                self.insertblurView()
                
            }).subscribe(onNext: {  [unowned self] _ in
                self.showChoice()
            })
                .disposed(by: viewModel.disposeBag)
                
                
                self.viewModel.userImage
                .observe(on: MainScheduler.instance)
                .flatMapLatest { [unowned self] in
                    self.processImage(imageData: $0)
                }
                .do(onNext: { [unowned self] _ in
                    
                    self.imageCropVC.dismiss(animated: true) {
                        
                        if let blurView = self.view.subviews.first(where: { $0.tag == 1}) {
                            blurView.removeFromSuperview()
                        }
                        
                    }
                    
                })
                    .subscribe(onNext: { data in
                        
                        guard let image = UIImage(data: data) else { return }
                        image.withRenderingMode(.alwaysOriginal)
                        self.userImageButton.setBackgroundImage(image, for: .normal)
                        
                    })
                    .disposed(by: viewModel.disposeBag)
                    
                    
                    
                    Observable.combineLatest(viewModel.userName.asObservable(), viewModel.email.asObservable(), viewModel.familySize.asObservable(), viewModel.cuisineType.asObservable()) { (name, email, familySize, cuisineType) -> Bool in
                        
                        if name.isNotEmpty && email.isNotEmpty && familySize.isNotEmpty && cuisineType.isNotEmpty {
                            return true
                        }
                        else {
                            return false
                        }
                    }
                    .bind(to: viewModel.isEnableDone)
                    .disposed(by: viewModel.disposeBag)
        
        doneButton.rx.tap
            .throttle(.milliseconds(1000), scheduler: MainScheduler.asyncInstance)
            .flatMap { [unowned self] in
                self.viewModel.registerUser()
            }
            .subscribe(onNext: { _ in
                
                self.viewModel.goToNext()
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        
    }
    
    fileprivate func setUpTxtFields() {
        
        userNameTextField.text = viewModel.user.displayName
        emailTextField.text = viewModel.user.email
        
        familyPicker.delegate = self
        familyPicker.dataSource = self
        
        cuisinePicker.delegate = self
        cuisinePicker.dataSource = self
        cuisinePicker.tag = 11
        familyPicker.tag = 10
        
        familySizeTextField.inputView = familyPicker
        cuisineTypeTextField.inputView = cuisinePicker
        
        familySizeTextField.tag = 100
        cuisineTypeTextField.tag = 200
        
        let bar = UIToolbar()
        bar.sizeToFit()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let endBtn = UIBarButtonItem()
        endBtn.title = "Done"
        
        endBtn.rx.tap
            .throttle(.microseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                
                self.view.endEditing(true)
                
            })
            .disposed(by: viewModel.disposeBag)
        
        
        bar.setItems([space, endBtn], animated: true)
        
        
        familySizeTextField.inputAccessoryView = bar
        cuisineTypeTextField.inputAccessoryView = bar
    }
    
    
    
    private func PickerColor(){
        
        familyPicker.setValue( #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) , forKey: "backgroundColor")
        familyPicker.setValue(#colorLiteral(red: 0.5170344114, green: 0.3871352673, blue: 0.1388392448, alpha: 1), forKey: "textColor")
        cuisinePicker.setValue( #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) , forKey: "backgroundColor")
        cuisinePicker.setValue(#colorLiteral(red: 0.5170344114, green: 0.3871352673, blue: 0.1388392448, alpha: 1), forKey: "textColor")
    }
    
    func insertblurView()  {
        
        
        // Init a UIVisualEffectView which going to do the blur for us
        let blurView = UIVisualEffectView()
        // Make its frame equal the main view frame so that every pixel is under blurred
        blurView.frame = view.frame
        // Choose the style of the blur effect to regular.
        // You can choose dark, light, or extraLight if you wants
        blurView.effect = UIBlurEffect(style: .dark)
        
        blurView.alpha = 0.3
        
        // Now add the blur view to the main view
        blurView.tag = 1
        
        let indicator = UIActivityIndicatorView()
        
        
        blurView.contentView.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        
        indicator.startAnimating()
        
        self.view.addSubview(blurView)
        
        self.view.bringSubviewToFront(blurView)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 10) {
            return viewModel.familySizeOptions.count
        }
        else {
            return viewModel.cuisineTypeOptions.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 10) {
            return viewModel.familySizeOptions[row]
        }
        else {
            return viewModel.cuisineTypeOptions[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView.tag == 10) {
            let familySizeTextField = self.view?.viewWithTag(100) as? UITextField
            familySizeTextField?.text = viewModel.familySizeOptions[row]
        }
        else {
            let cuisineTypeTextField = self.view?.viewWithTag(200) as? UITextField
            cuisineTypeTextField?.text = viewModel.cuisineTypeOptions[row]
        }
    }
    
    func takeYourImage() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .camera
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    
    /// アラート表示
    func showAlert() {
        
        let alert = UIAlertController(title: "Allow to access your photo library",
                                      message: "This app need to access your photo library. In order to allow that, \ngo to Settings -> Recipe-CICCC -> Photos",
                                      preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        // アラートにボタン追加
        alert.addAction(cancelButton)
        
        // アラート表示
        present(alert, animated: true, completion: nil)
    }
    
    func showChoice() {
        
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertStyle = UIAlertController.Style.alert
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
        
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default, handler: { [unowned self] action in
            
            self.viewModel.toPickPhoto()
            
        })
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [unowned self] action in
            
            self.viewModel.toCamera()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        })
        actionSheet.addAction(cameraRollAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        actionSheet.modalPresentationStyle = .popover
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func processImage(imageData: Data) -> Observable<Data> {
        
        if let image = UIImage(data: imageData) {
            
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            
            imageCropVC.moveAndScaleLabel.text = "Triming"
            imageCropVC.cancelButton.setTitle("Cancel", for: .normal)
            imageCropVC.chooseButton.setTitle("Done", for: .normal)
            
            self.present(imageCropVC, animated: true)
            
        } else {
            print("failed")
        }
        
        return imageCropVC.rx.imageData.map { $0 }
    }
    
}

extension RegisterMyInfoProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
}

