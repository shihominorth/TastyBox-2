//
//  RxPHPickerViewControllerDelegateProxy.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-20.
//

import Foundation
import Photos
import PhotosUI
import RxSwift
import RxCocoa

class RxPHPickerViewControllerDelegateProxy: DelegateProxy<PHPickerViewController, PHPickerViewControllerDelegate>,  PHPickerViewControllerDelegate {
    
    public weak private(set) var picker: PHPickerViewController?
    internal lazy var imageSubject = PublishSubject<Data>()
    internal lazy var urlSubject = PublishSubject<URL>()
    
    public init(picker: PHPickerViewController) {
        self.picker = picker
        super.init(parentObject: picker, delegateProxy: RxPHPickerViewControllerDelegateProxy.self)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
       
        Thread.sleep(forTimeInterval: 0.5)

        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            
            provider.loadObject(ofClass: UIImage.self) { [unowned self] image, err in
                
                if let err = err {
                    
                    print(err)
                    
                }
                else if let image = image as? UIImage, let data = image.convertToData() {
                    
                    
                    self.imageSubject.onNext(data)
                    
                }
                
            }
            
        }
        else if provider.hasItemConformingToTypeIdentifier(UTType.video.identifier) ||  provider.hasItemConformingToTypeIdentifier(UTType.quickTimeMovie.identifier) {
            
            guard let typeIdentifier = provider.registeredTypeIdentifiers.first else { return }

            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [unowned self] url, err in
                
                if let err = err {
                    
                    self.urlSubject.onError(err)
                    
                }
                else if let url = url as? URL {
                    
                    self.urlSubject.onNext(url)
                    
                }
            
            }
        }
        
    }
    
}


extension RxPHPickerViewControllerDelegateProxy: DelegateProxyType {
    static func registerKnownImplementations() {
        register { RxPHPickerViewControllerDelegateProxy(picker: $0) }
    }
    
    static func currentDelegate(for object: PHPickerViewController) -> PHPickerViewControllerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: PHPickerViewControllerDelegate?, to object: PHPickerViewController) {
        object.delegate = delegate
    }
    
    
}

extension Reactive where Base: PHPickerViewController {
    
    public var delegate: DelegateProxy<PHPickerViewController, PHPickerViewControllerDelegate> {
        return self.delegate
    }
    
    public var imageData: Observable<Data> {
        
        let proxy = RxPHPickerViewControllerDelegateProxy.proxy(for: base)
        proxy.imageSubject = PublishSubject<Data>()
        
        return proxy.imageSubject.asObservable()
    }
    
    public var videoUrl: Observable<URL> {
        
        let proxy = RxPHPickerViewControllerDelegateProxy.proxy(for: base)
        proxy.urlSubject = PublishSubject<URL>()
        
        return proxy.urlSubject.asObservable()
    }
}
