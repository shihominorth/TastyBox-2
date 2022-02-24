//
//  CreateRecipeVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-16.
//

import Foundation
import Action
import Firebase
import Photos
import RxSwift
import RxCocoa
import RxRelay
import SCLAlertView



enum RecipeInput {
    case mainPhoto(Observable<Data>), isAddedVideo(Observable<Bool>), videoURL(Observable<URL>), title(Observable<String>), time(Observable<String>), serving(Observable<String>), isVIP(Observable<Bool>), selectedGenres(Observable<[Genre]>), ingredients(Observable<[Ingredient]>), instructions(Observable<[Instruction]>)
}

final class CreateRecipeVM: ViewModelBase {
    
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
    
    var videoPlaySubject = BehaviorSubject<URL>(value: URL(fileURLWithPath: ""))
    
    var isAddedSubject = BehaviorSubject<Bool>(value: false)
    
    var mainImgDataSubject = BehaviorSubject<Data>(value: Data())
    var thumbnailImgDataSubject = BehaviorSubject<Data>(value: Data())
    
    let titleSubject = BehaviorSubject<String>(value: "")
    let servingSubject = BehaviorSubject<Int>(value: 0)
    let timeSubject = BehaviorSubject<Int>(value: 0)
    let selectedGenres = BehaviorRelay<[Genre]>(value: [])
    var isVIPSubject = BehaviorSubject<Bool>(value: false)
    
    
    var ingredients = [Ingredient]()
    var instructions = [Instruction]()
    
    var ingredientsSubject = BehaviorSubject<[Ingredient]>(value: [])
    var instructionsSubject = BehaviorSubject<[Instruction]>(value: [])
    
    let isMainImgValidation:  Observable<Bool>
    let isTitleValidation:  Observable<Bool>
    let isTimeValidation:  Observable<Bool>
    let isServingValidation:  Observable<Bool>
    let ingredientValidation: Observable<Bool>
    let instructionValidation: Observable<Bool>
    
    let combinedRequirements: Observable<(Bool, Bool, Bool, Bool)>
    let combinedIngredientAndInstructionValidation: Observable<(Bool, Bool)>
    
//    let stringInputs: Observable<(String, StrstringInputsing, String)>
    let combinedInputs: [RecipeInput]
    let isIngredienstNotEmpty = PublishSubject<Bool>()
    let isInstructionsNotEmpty = PublishSubject<Bool>()
    
    var pickingImgIndexSubject = PublishSubject<Int>()
    
    var isExpanded = false
    let selectedTimeSubject: BehaviorRelay<String>
    let mainImgKind: DigitalContentsFor.RecipeMain
    
    init(sceneCoodinator: SceneCoordinator, user: Firebase.User, imgData: Data, videoUrl: URL?, kind: DigitalContentsFor.RecipeMain, apiType: CreateRecipeDMProtocol.Type = CreateRecipeDM.self) {
        
        self.sceneCoodinator = sceneCoodinator
        self.user = user
        self.apiType = apiType
        
        self.selectedTimeSubject = BehaviorRelay<String>(value: "")
        
        self.ingredients = []
        self.ingredientsSubject = BehaviorSubject<[Ingredient]>(value: self.ingredients)
        
        self.isMainImgValidation = self.mainImgDataSubject
            .map { !$0.isEmpty }
            .share(replay: 1, scope: .forever)
        
        self.isTitleValidation = self.titleSubject
            .map { !$0.isEmpty }
            .share(replay: 1, scope: .forever)
        
        
        self.isTimeValidation = self.selectedTimeSubject
            .filter { !$0.isEmpty }
            .map { txt in
                let txtArr = txt.components(separatedBy: " ").filter { $0 != "" }.filter { $0 != "hours" }.filter { $0 != "mins" }
                return (txtArr[0] == "0") && (txtArr[1] == "0")
            }
            .share(replay: 1, scope: .forever)
        
        self.isServingValidation = self.servingSubject
            .map { !String($0).isEmpty }
            .share(replay: 1, scope: .forever)
        
        self.ingredientValidation = self.ingredientsSubject
            .map { $0[0] }
            .debug()
            .map { !$0.name.isEmpty && !$0.amount.isEmpty }
            .share(replay: 1, scope: .forever)
        
        self.instructionValidation = self.instructionsSubject.map { $0[0] }
        .map { !$0.text.isEmpty }
        .share(replay: 1, scope: .forever)
        
        self.combinedRequirements = .combineLatest(self.isMainImgValidation, self.isTitleValidation, self.isTimeValidation, self.isServingValidation) { isMainImgValid, isTitleValid, isTimeValid, isServingValid in
            
            return (isMainImgValid, isTitleValid, isTitleValid, isServingValid)
        }
        
        self.combinedIngredientAndInstructionValidation = .combineLatest(ingredientValidation, instructionValidation) { isIngredientValid, isInstructionValid in
            return (isIngredientValid, isInstructionValid)
        }
        
        self.mainImgDataSubject.onNext(imgData)
        self.combinedInputs = [.mainPhoto(self.mainImgDataSubject)]

        self.mainImgKind = kind
        
//        super.init()
        
        switch kind {
        case .video:
            thumbnailImgDataSubject.onNext(imgData)
        default:
            break
        }
        
    }
    
    func isFilledRequirement(isMainImgValid: Bool, isTitleValid: Bool, isTimeValid: Bool, isServingValid: Bool) -> Observable<Bool> {
        
        
        return Observable.create { observer in
            
            var notValidRequirements: [String] = []
            
            if !isMainImgValid {
                notValidRequirements.append("Main Photo Image")
            }
            if !isTitleValid {
                notValidRequirements.append("Title")
            }
            if !isTimeValid {
                notValidRequirements.append("Time")
            }
            if !isServingValid {
                notValidRequirements.append("Servings")
            }
            
            
            if notValidRequirements.isEmpty {
                observer.onNext(true)
            }
            else {
                
                var subtitle = notValidRequirements.joined(separator: "\n・ ")
                subtitle.insert("・", at: subtitle.startIndex)
                
                
                SCLAlertView().showTitle(
                    "Empty requirement below", // Title of view
                    subTitle: subtitle,
                    timeout: .none, // String of view
                    completeText: "Done", // Optional button value, default: ""
                    style: .error, // Styles - see below.
                    colorStyle: 0xA429FF,
                    colorTextButton: 0xFFFFFF
                )
                
                observer.onNext(false)
            }
            
            return Disposables.create()
            
        }
        
        
    }
    
    func isIngredientsAndInstructions(isIngredientValid: Bool, isInstructionValid: Bool) -> Observable<Bool> {
        
        return Observable.create { observer in
            
            var notValidRequirements: [String] = []
            
            if !isIngredientValid {
                notValidRequirements.append("Ingredients")
            }
            if !isInstructionValid {
                notValidRequirements.append("Instructions")
            }
            
            
            if notValidRequirements.isEmpty {
                observer.onNext(true)
            }
            else {
                
                let title: String? = {
                    
                    if !isIngredientValid && !isInstructionValid {
                        
                        return "Ingredients and Instructions"
                    }
                    else if !isIngredientValid {
                        
                        return "Ingredients"
                        
                    }
                    else if !isInstructionValid {
                        
                        return "Instructions"
                    }
                    
                    return nil
                }()
                
                let subtitle = notValidRequirements.joined(separator: "\n・ ")
                
                if let title = title {
                    
                    SCLAlertView().showTitle(
                        "You need at least one \(title)  below", // Title of view
                        subTitle: subtitle,
                        timeout: .none, // String of view
                        completeText: "Done", // Optional button value, default: ""
                        style: .error, // Styles - see below.
                        colorStyle: 0xA429FF,
                        colorTextButton: 0xFFFFFF
                    )
                }
                
                observer.onNext(false)
                
            }
            
            return Disposables.create()
            
        }
        
        
    }
    
    func goToNext(){
        
        Observable.zip(self.mainImgDataSubject.asObservable(), isAddedSubject.asObservable(), videoPlaySubject.asObservable(), titleSubject.asObservable(), selectedTimeSubject.asObservable(), servingSubject.asObservable(), isVIPSubject.asObservable(), selectedGenres.asObservable())
            .flatMap { mainImageData, isAdded, url, title, timeString, serving, isVIP, genres  -> Observable<CheckRecipeVM> in
                
                let url = isAdded ? url : nil
                
                let filteredIngredients = self.ingredients.filter { !$0.name.isEmpty }.enumerated()
                    .map { index, value -> Ingredient in

                        let newElement = value
                        newElement.index = index

                        return newElement
                    }

                
                let filteredInstructions = self.instructions.filter { !$0.text.isEmpty }.enumerated()
                    .map { index, value -> Instruction in
                        
                        var newElement = value
                        newElement.index = index
                        
                        return newElement
                    }
                
                let txtArr = timeString.components(separatedBy: " ").filter { $0 != "" }.filter { $0 != "hours" }.filter { $0 != "mins" }
                
                let time = (Int(txtArr[0]) ?? 0) * 60 + (Int(txtArr[1]) ?? 0)
                
                let vm = CheckRecipeVM(sceneCoodinator: self.sceneCoodinator, user: self.user, title: title, mainPhoto: mainImageData, videoUrl: url, time: time, serving: serving, isVIP: isVIP, genres: genres, ingredients: filteredIngredients, instructions: filteredInstructions)
                
                return Observable.just(vm)
                
            }
            .subscribe(onNext: { [unowned self] vm in
                
                self.sceneCoodinator.transition(to: .createReceipeScene(scene: .checkRecipe(vm)), type: .push)
                
            })
            .disposed(by: disposeBag)
        
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

        let indredient = Ingredient(key: uniqueIdString, name: "", amount: "", index: self.ingredients.count)

        self.ingredients.append(indredient)
        self.ingredientsSubject.onNext(self.ingredients)
    }
    

    
    func appendNewInstructions() {
        
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        
        let instruction = Instruction(id: uniqueIdString, index: self.instructions.count, imageURL: "", text: "")
        
        self.instructions.append(instruction)
        self.instructionsSubject.onNext(self.instructions)
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
    
    func toSelectDigitalContentsVC(kind: DigitalContentsFor) {
        
        let vm = SelectDigitalContentsVM(sceneCoodinator: self.sceneCoodinator, user: self.user, kind: kind, isEnableSelectOnlyOneDigitalContentType: true)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectDigitalContents(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: true))

    }
    
    func toSelectThumbnail(imageData: Data) {
        
        let vm = SelectThumbnailVM(sceneCoodinator: self.sceneCoodinator, user: self.user, imageData: imageData)
        let scene: Scene = .digitalContentsPickerScene(scene: .selectThumbnail(vm))
    
        vm.delegate = self
        
        self.sceneCoodinator.transition(to: scene, type: .modal(presentationStyle: .fullScreen, modalTransisionStyle: .coverVertical, hasNavigationController: true))

    }
    
    func instructionsToImagePicker(index: Int) -> Observable<Data> {
        
        let subject = PublishSubject<Data>()
        let scene: Scene = .digitalContentsPickerScene(scene: .photo)
        
        self.sceneCoodinator.transition(to: scene, type: .photoPick(completion: { data in
            
            let str = String(decoding: data, as: UTF8.self)
            
            self.instructions[index].imageURL =  URL(string: str)?.absoluteString
            
            self.sceneCoodinator.userDismissed { _ in
                
                subject.onNext(data)
                
            }

            
        }))

        
        return subject.asObservable()
        
    }
    
    func toImagePicker() {
        
        let scene: Scene = .digitalContentsPickerScene(scene: .photo)
        
        self.sceneCoodinator.transition(to: scene, type: .photoPick(completion: { data in
            
            self.sceneCoodinator.userDismissed()
            
            self.mainImgDataSubject.onNext(data)
            
        }))
        
    }
    
    
    func getImage() -> Observable<Data> {
        
        return photoPicker.rx.imageData
            .catch { err in
                
                print(err)

                return .empty()
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [unowned self] in
                
                self.sceneCoodinator.userDismissed()
                
                self.mainImgDataSubject.onNext($0)
                
            })
                
    }
    
    func toVideoPicker() {
        
        let scene: Scene = .digitalContentsPickerScene(scene: .video)
        
        self.sceneCoodinator.transition(to: scene, type: .videoPick(compeletion: { [unowned self] url in
            
            self.videoPlaySubject.onNext(url)
            
        }))
        
    }
    
    func getVideoUrl() -> Observable<URL> {
        
        return videoPicker.rx.videoUrl
            .catch { err in
                
                print(err)
                
                return .empty()
            }
            .map { $0 }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [unowned self] in
               
                self.sceneCoodinator.userDismissed()
                self.videoPlaySubject.onNext($0)
                
            })
    }
    
    func playVideo(url: URL) {
        
        
        let vm = UploadingVideoVM(sceneCoodinator: self.sceneCoodinator, user: self.user, url: url)
        vm.delegate = self
        let scene: Scene = .createReceipeScene(scene: .uploadingVideo(vm))
        
        self.sceneCoodinator.transition(to: scene, type: .modalHalf)
        
    }
    
    func getThumbnail(url: URL) -> Observable<Data> {
        
        return isAddedSubject
            .filter { $0 }
            .flatMap { [unowned self] _ in self.apiType.getThumbnailData(url: url) }
        
    }
    
    func goToAddGenres(genres: [Genre]) {
        
        let vm = SelectGenresVM(sceneCoordinator: self.sceneCoodinator, user: self.user, genres: genres)
        
        self.sceneCoodinator.transition(to: Scene.createReceipeScene(scene: .selectGenre(vm)), type: .modal(presentationStyle: .automatic, modalTransisionStyle: .coverVertical, hasNavigationController: true))
            .asObservable()
            .subscribe(onError: { err in
                
                print(err)
                
            }, onCompleted: { [unowned self] in
                
                vm.delegate = self
                
            })
            .disposed(by: disposeBag)
        
        
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

extension CreateRecipeVM: SelectThumbnailDelegate {
 
    func selectedThumbnail(imageData: Data) {

        mainImgDataSubject.onNext(imageData)

    }

}

