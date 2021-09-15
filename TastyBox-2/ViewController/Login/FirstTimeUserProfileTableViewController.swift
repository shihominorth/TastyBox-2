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
//import FBSDKLoginKit
//import Crashlytics


class FirstTimeUserProfileTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, BindableType {
    
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
    
//    let uid = Auth.auth().currentUser?.uid
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        userNameTextField.text = viewModel.user.displayName
        emailTextField.text = viewModel.user.email
        
        //        var ref: DatabaseReference!
        //        ref = Database.database().reference()
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
        
        PickerColor()
        
        userImageButton.imageView?.contentMode = .scaleAspectFit
        userImageButton.layer.cornerRadius = 0.5 * userImageButton.bounds.size.width
        userImageButton.clipsToBounds = true
      
        guard let data = viewModel.userImage.value, let image = UIImage(data: data) else { return }
        image.withRenderingMode(.alwaysOriginal)
        userImageButton.setImage(image, for: .normal)
       
    }
    
    
    func bindViewModel() {
        
        
        
        let _ = viewModel.isEnableDone.bind(to: doneButton.rx.isEnabled)
        
        
        //MARK: 全てのテキストフィールドのどれか一つが変化するとき、全てのテキストフィールドが空じゃないか調べる。
        // 全てのテキストフィールドが埋まっていたらDoneボタンを使用できるようにする
        // https://medium.com/@dannylazarow/rxswift-reverse-observable-aka-two-way-binding-5027cbfdc6f0
        
        let info = Observable.combineLatest(userNameTextField.rx.text.orEmpty, emailTextField.rx.text.orEmpty, familySizeTextField.rx.text.orEmpty, cuisineTypeTextField.rx.text.orEmpty, viewModel.userImage)
        
            
        _ = userNameTextField.rx.text.orEmpty.bind(to: viewModel.userName)
        _ = emailTextField.rx.text.orEmpty.bind(to: viewModel.email)
        _ = familySizeTextField.rx.text.orEmpty.bind(to: viewModel.familySize)
        _ = cuisineTypeTextField.rx.text.orEmpty.bind(to: viewModel.cuisineType)

        
        let _ = Observable.combineLatest(viewModel.userName.asObservable(), viewModel.email.asObservable(), viewModel.familySize.asObservable(), viewModel.cuisineType.asObservable())
            .subscribe { (name, email, familySize, cuisineType) in
            
            if name.isNotEmpty && email.isNotEmpty && familySize.isNotEmpty && cuisineType.isNotEmpty {
                self.viewModel.isEnableDone.accept(true)
            }
            else {
                self.viewModel.isEnableDone.accept(false)
            }
        }
        
     
        
        doneButton.rx.tap
            .withLatestFrom(info)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.asyncInstance)
            .bind(to: viewModel.registerUserAction.inputs)
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
    
    @IBAction func finishFirstTimeProfile(_ sender: Any) {
        if userNameTextField.text == "" || emailTextField.text == "" || familySizeTextField.text == "" || cuisineTypeTextField.text == ""{
            let alertController = UIAlertController(title: "Error", message: "Please enter simple info to have better using experience", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            // account image should convert from uiimage to data?
            // in order to convert it, use .jpegData() before call userRegister.
            
            viewModel.userRegister(userName: userNameTextField.text, email: emailTextField.text, familySize: familySizeTextField.text, cuisineType: cuisineTypeTextField.text, accountImage: userImageButton.imageView?.image?.defineUserImage())
            //            dataManager.userRegister(userName: userNameTextField.text ?? "", eMailAddress: emailTextField.text ?? "", familySize: Int(familySizeTextField!.text!) ?? 0, cuisineType: cuisineTypeTextField!.text ?? "", accountImage: userImage!, isVIP: isVIP)
            
            
            //            if Auth.auth().currentUser?.displayName == nil {
            //                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            //                changeRequest?.displayName = userNameTextField.text
            //            }
            //
            //            let Storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            //            let vc = Storyboard.instantiateViewController(withIdentifier: "Discovery")
            //            vc.modalTransitionStyle = .crossDissolve
            //            vc.modalPresentationStyle = .overFullScreen
            //
            //            guard self.navigationController?.topViewController == self else { return }
            //
            //            if Auth.auth().currentUser?.uid != nil {
            //                self.navigationController?.pushViewController(vc, animated: false)
            //                } else {
            //
            //            }
            
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

extension FirstTimeUserProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension FirstTimeUserProfileTableViewController:  RSKImageCropViewControllerDelegate {
    
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

//extension FirstTimeUserProfileTableViewController: getUserDataDelegate {
//    func gotUserData(user: User) {
//        self.familySizeTextField.text = String(user.familySize!)
//        self.cuisineTypeTextField.text = user.cuisineType
//
//        if let isVIP = user.isVIP {
//            self.isVIP = isVIP
//        }
//
//        if Auth.auth().currentUser?.displayName == nil {
//            self.userNameTextField.text = user.name
//        }
//
//        var rowNumberCuisineType: Int {
//            var temp: Int?
//
//            cuisineType.map { if $0 == self.cuisineTypeTextField.text {
//                temp = cuisineType.firstIndex(of: $0)
//                }
//            }
//
//            return temp ?? 0
//        }
//
//        self.cuisinePicker.selectRow(rowNumberCuisineType, inComponent: 0, animated: true)
//
//        var rowNumberFamilySize: Int {
//            var temp: Int?
//
//            familySize.map { if $0 == self.familySizeTextField.text {
//                temp = familySize.firstIndex(of: $0)
//                }
//            }
//
//            return temp!
//        }
//
//        self.familyPicker.selectRow(rowNumberFamilySize, inComponent: 0, animated: true)
//    }
//
//    func assignUserImage(image: UIImage) {
//        self.userImage = image
//        self.userImageButton.setBackgroundImage(image, for: .normal)
//        doneButton.isEnabled = true
//    }
//
//}
