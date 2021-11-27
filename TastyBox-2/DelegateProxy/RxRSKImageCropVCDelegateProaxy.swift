//
//  RxRSKImageCropVCDelegateProaxy.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-27.
//

import Foundation
import Photos
import PhotosUI
import RSKImageCropper
import RxSwift
import RxCocoa

class RxRSKImageCropVCDelegateProaxy: DelegateProxy<RSKImageCropViewController, RSKImageCropViewControllerDelegate>,  RSKImageCropViewControllerDelegate {

    public weak private(set) var cropVC: RSKImageCropViewController?
    internal lazy var imageSubject = PublishSubject<Data>()
    
    public init(cropVC: RSKImageCropViewController) {
        self.cropVC = cropVC
        super.init(parentObject: cropVC, delegateProxy: RxRSKImageCropVCDelegateProaxy.self)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
    
        self.cropVC?.dismiss(animated: true, completion: nil)
    
    }
    
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
//            let png = UIImage(data: pngData)!
            
            
            UserDefaults.standard.set(pngData, forKey: "userImage")
            self.imageSubject.onNext(pngData)
            
            
            
        }
    }
    
    
}


extension RxRSKImageCropVCDelegateProaxy: DelegateProxyType {
   
    static func registerKnownImplementations() {
        register { RxRSKImageCropVCDelegateProaxy(cropVC: $0) }
    }
    
    static func currentDelegate(for object: RSKImageCropViewController) -> RSKImageCropViewControllerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RSKImageCropViewControllerDelegate?, to object: RSKImageCropViewController) {
        object.delegate = delegate
    }
    
}

extension Reactive where Base: RSKImageCropViewController {
    
    public var delegate: DelegateProxy<RSKImageCropViewController, RSKImageCropViewControllerDelegate> {
        return self.delegate
    }
    
    public var imageData: Observable<Data> {
        
        let proxy = RxRSKImageCropVCDelegateProaxy.proxy(for: base)
        proxy.imageSubject = PublishSubject<Data>()
        
        return proxy.imageSubject.asObservable()
    }
    
}
