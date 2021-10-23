//
//  CreateRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import Foundation
import Action
import Firebase
import RxSwift
import RxCocoa
import UIKit
//import UIKit

class CreateRecipeVM: ViewModelBase {
    
    let sceneCoodinator: SceneCoordinator
    let user: Firebase.User
    
    let apiType: CreateRecipeDMProtocol.Type
    
    let keyboardOpen = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).observe(on: MainScheduler.instance)
    
    let keyboardClose = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).observe(on: MainScheduler.instance) //全部終わったらkeyboard sizeだけ返すようにする
    
    var isUserScrollingRelay = BehaviorRelay<Bool>(value: true)
    
    var isEditableIngredientsRelay = BehaviorRelay<Bool>(value: false)
    var isEditInstructionsRelay = BehaviorRelay<Bool>(value: false)
    
    let photoPicker = ImagePickScene.photo.viewController()
    let videoPicker = ImagePickScene.video.viewController()
    
    var videoPlaySubject = PublishSubject<URL>()
    
    var isAddedSubject = BehaviorSubject<Bool>(value: false)
    
    var mainImgDataSubject: Observable<Data>!
    var thumbnailImgDataSubject: Observable<Data>!
    
    let titleSubject = PublishSubject<String>()
    let servingSubject = PublishSubject<Int>()
    let timeSubject = PublishSubject<Int>()
    let selectedGenres = BehaviorRelay<[Genre]>(value: [])
    
    var isVIPSubject = PublishSubject<Bool>()
    
    var ingredients = [Ingredient]()
    var instructions = [Instruction]()
    
    var pickingImgIndexSubject = PublishSubject<Int>()
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        
        super.init()
        
        mainImgDataSubject = photoPicker.rx.imageData
        
    }
    
    func isAppendNewIngredient() -> Observable<Bool> {
        
        return Observable.create { [unowned self] observer in
            
            appendNewIngredient()
            
            observer.onNext(true)
            
            return Disposables.create()
        }
        
        
    }
    
    func isAppendNewInstructions() -> Observable<Bool> {
        
        return Observable.create { [unowned self] observer in
            
            appendNewInstructions()
            
            observer.onNext(true)
            
            return Disposables.create()
        }
        
        
    }
    
    
    func appendNewIngredient() {
        
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        
        let indredient = Ingredient(key: uniqueIdString, name: "", amount: "", order: self.ingredients.count)
        
        self.ingredients.append(indredient)
    }
    
    func appendNewInstructions() {
        
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        
        let instruction = Instruction(index: self.instructions.count, imageData: Data(), text: "")
        
        self.instructions.append(instruction)
    }
    
    
    func setIsEditableTableViewRelay() -> Observable<Bool> {
        
        return Observable.create { observer in
            
            self.isEditableIngredientsRelay.accept(!self.isEditableIngredientsRelay.value)
            
            observer.onNext(true)
            
            return Disposables.create()
        }
    }
    
    func setIsEditInstructionRelay() -> Observable<Bool> {
        
        return Observable.create { observer in
            
            self.isEditInstructionsRelay.accept(!self.isEditInstructionsRelay.value)
            
            observer.onNext(true)
            
            return Disposables.create()
        }
    }
    
    func instructionsToImagePicker(index: Int) -> Observable<Data> {
        
        self.sceneCoodinator.transition(to: photoPicker, type: .imagePick)
        
        return photoPicker.rx.imageData
            .catch { err in
                
                print(err)
                
                return .empty()
            }
            .do(onNext: { [unowned self] data in
                
                self.instructions[index].imageData = data
                
            })
                
                }
    
    func toImagePicker() {
        
        self.sceneCoodinator.transition(to: photoPicker, type: .imagePick)
        
    }
    
    func getImage() -> Observable<Data> {
        
        return photoPicker.rx.imageData
            .catch { err in
                
                print(err)
                
                return .empty()
            }
    }
    
    func toVideoPicker() {
        
        self.sceneCoodinator.transition(to: self.videoPicker, type: .imagePick)
        
    }
    
    func getVideoUrl() -> Observable<URL> {
        
        return videoPicker.rx.videoUrl
            .catch { err in
                
                print(err)
                
                return .empty()
            }
            .map { $0 }
    }
    
    func playVideo(url: URL) {
        
        
        let vm = UploadingVideoVM(sceneCoodinator: self.sceneCoodinator, user: self.user, url: url)
        vm.delegate = self
        let vc = VideoScene.player(vm).viewController()
        
        self.sceneCoodinator.transition(to: vc, type: .modalHalf)
        
    }
    
    func getThumbnail(url: URL) -> Observable<Data> {
        
        return isAddedSubject
            .filter { $0 }
            .flatMap { [unowned self] _ in self.apiType.getThumbnailData(url: url) }
        
    }
    
    func goToAddGenres(genres: [Genre]) {
        
        let vm = SelectGenresVM(sceneCoordinator: self.sceneCoodinator, user: self.user, genres: genres)
        
        self.sceneCoodinator.modalTransition(to: Scene.createReceipeScene(scene: .selectGenre(vm)), type: .modal(.automatic, .coverVertical))
            .asObservable()
            .subscribe(onError: { err in
               
                print(err)
                
            }, onCompleted: { [unowned self] in
                
                vm.delegate = self
                
            })
            .disposed(by: disposeBag)
        
//        self.sceneCoodinator.modalTransition(to: Scene.createReceipeScene(scene: .selectGenre(vm)), type: .push)
        
    }
    
}

extension CreateRecipeVM: SelectGenreProtocol {
    func addGenre(genres: [Genre]) {
        
        self.selectedGenres.accept(genres)
        
    }
}

extension CreateRecipeVM: UploadingVideoVMDelegate {
    
    func addVideo(isAdded: Bool) {
        
        isAddedSubject.onNext(isAdded)
        
    }
}

