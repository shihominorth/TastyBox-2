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


class RegisterMyInfoProfileTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, BindableType, KeyboardSetUpProtocol {
    
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
        let endBtn = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(closeKeyboard))
        bar.items = [endBtn]
        bar.sizeToFit()
        
        familySizeTextField.inputAccessoryView = bar
        cuisineTypeTextField.inputAccessoryView = bar
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpTxtFields()
        
        setUpKeyboard()
        
        PickerColor()
        
        userImageButton.imageView?.contentMode = .scaleAspectFit
        userImageButton.layer.cornerRadius = 0.5 * userImageButton.bounds.size.width
        userImageButton.clipsToBounds = true
        
        
        
    }
    
    
    func bindViewModel() {
        
        let _ = viewModel.isEnableDone.bind(to: doneButton.rx.isEnabled)
        
        //        let info = Observable.combineLatest(userNameTextField.rx.text.orEmpty, emailTextField.rx.text.orEmpty, familySizeTextField.rx.text.orEmpty, cuisineTypeTextField.rx.text.orEmpty, viewModel.userImage)
        
        
        userNameTextField.rx.text.orEmpty.bind(to: viewModel.userName).disposed(by: viewModel.disposeBag)
        emailTextField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: viewModel.disposeBag)
        familySizeTextField.rx.text.orEmpty.bind(to: viewModel.familySize).disposed(by: viewModel.disposeBag)
        cuisineTypeTextField.rx.text.orEmpty.bind(to: viewModel.cuisineType).disposed(by: viewModel.disposeBag)
        
        self.viewModel.getUserImage()
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
    
    
    
    
    private func PickerColor(){
        
        familyPicker.setValue( #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) , forKey: "backgroundColor")
        familyPicker.setValue(#colorLiteral(red: 0.5170344114, green: 0.3871352673, blue: 0.1388392448, alpha: 1), forKey: "textColor")
        cuisinePicker.setValue( #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) , forKey: "backgroundColor")
        cuisinePicker.setValue(#colorLiteral(red: 0.5170344114, green: 0.3871352673, blue: 0.1388392448, alpha: 1), forKey: "textColor")
    }
    
    @objc func closeKeyboard(){
        self.view.endEditing(true)
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
    
    
    func selectPicture() {
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                
                DispatchQueue.main.async {
                    // 写真を選ぶビュー
                    let pickerView = UIImagePickerController()
                    // 写真の選択元をカメラロールにする
                    // 「.camera」にすればカメラを起動できる
                    pickerView.sourceType = .photoLibrary
                    // デリゲート
                    pickerView.delegate = self
                    // ビューに表示
                    self.present(pickerView, animated: true)
                }
                
                
            case .restricted:
                break
            case .denied:
                DispatchQueue.main.async {
                    // アラート表示
                    self.showAlert()
                }
                
            default:
                // place for .notDetermined - in this callback status is already determined so should never get here
                break
            }
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
    
    
    @IBAction func showChoice(_ sender: AnyObject) {
        
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertStyle = UIAlertController.Style.alert
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
        
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default, handler: { action in
            self.selectPicture()
        })
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            self.takeYourImage()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        })
        actionSheet.addAction(cameraRollAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        actionSheet.modalPresentationStyle = .popover
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}

extension RegisterMyInfoProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image : UIImage = info[.originalImage] as! UIImage
        
        imagePicker.dismiss(animated: false, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            
            imageCropVC.moveAndScaleLabel.text = "Triming"
            imageCropVC.cancelButton.setTitle("Cancel", for: .normal)
            imageCropVC.chooseButton.setTitle("Done", for: .normal)
            
            imageCropVC.delegate = self
            
            self.present(imageCropVC, animated: true)
        })
    }
}

extension RegisterMyInfoProfileTableViewController:  RSKImageCropViewControllerDelegate {
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        
        //もし円形で画像を切り取りし、その画像自体を加工などで利用したい場合
        if controller.cropMode == .circle {
            UIGraphicsBeginImageContext(croppedImage.size)
            let layerView = UIImageView(image: croppedImage)
            layerView.frame.size = croppedImage.size
            layerView.layer.cornerRadius = layerView.frame.size.width * 0.5
            layerView.clipsToBounds = true
            let context = UIGraphicsGetCurrentContext()!
            layerView.layer.render(in: context)
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let pngData = capturedImage.pngData()!
            //このImageは円形で余白は透過です。
            let png = UIImage(data: pngData)!
            
            
            UserDefaults.standard.set(pngData, forKey: "userImage")
            viewModel.userImage.accept(pngData)
            userImageButton.setBackgroundImage(png, for: .normal)
            dismiss(animated: true, completion: nil)
        }
    }
    
    //トリミング画面でキャンセルを押した時
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

