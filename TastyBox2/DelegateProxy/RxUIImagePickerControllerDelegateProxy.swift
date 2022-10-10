//
//  RxUIImagePickerControllerDelegateProxy.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-27.
//

import Foundation
import Photos
import PhotosUI
import RxSwift
import RxCocoa

class RxUIImagePickerControllerDelegateProxy: DelegateProxy<UIImagePickerController, (UIImagePickerControllerDelegate & UINavigationControllerDelegate)>,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public weak private(set) var picker: UIImagePickerController?
    internal lazy var imageSubject = PublishSubject<Data>()
    
    public init(picker: UIImagePickerController) {
        self.picker = picker
        super.init(parentObject: picker, delegateProxy: RxUIImagePickerControllerDelegateProxy.self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let image = info[.originalImage] as? UIImage, let data = image.convertToData() {
            
            picker.dismiss(animated: false, completion: { [unowned self] in
                
                self.imageSubject.onNext(data)
                
            })
        }
  
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: false)
        
    }
    
}

extension RxUIImagePickerControllerDelegateProxy: DelegateProxyType {
    
    static func registerKnownImplementations() {
        register { RxUIImagePickerControllerDelegateProxy(picker: $0) }
    }
    
    static func currentDelegate(for object: UIImagePickerController) -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, to object: UIImagePickerController) {
    
        object.delegate = delegate
    
    }
    
    
}

extension Reactive where Base: UIImagePickerController {
    
    public var delegate: DelegateProxy<UIImagePickerController,  (UIImagePickerControllerDelegate & UINavigationControllerDelegate)> {
        return RxUIImagePickerControllerDelegateProxy.proxy(for: base)
    }
    
    public var imageData: Observable<Data> {
        
        let proxy = RxUIImagePickerControllerDelegateProxy.proxy(for: base as RxUIImagePickerControllerDelegateProxy.ParentObject)
        proxy.imageSubject = PublishSubject<Data>()
        
        return proxy.imageSubject.asObservable()
    }
 
}
