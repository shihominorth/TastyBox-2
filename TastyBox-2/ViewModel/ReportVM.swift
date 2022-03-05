//
//  ReportVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-12-11.
//

import Foundation
import RxSwift

enum ReportReason: String {
    case harrasmentAndCyberbullying = "Harrasment and Cyberbullying"
    case privacy = "Privacy"
    case impersonation = "Impersonation" //なりすまし
    case violent = "Viorent thereads"
    case childEndangerment = "Child Endangerment"
    case hateSpeech = "Hate Speech against a Protected Group"
    case spamAndScams = "Spam and Scams"
    case others = "Others"
}

enum ReportKind: String {
    case recipe, comment, post
}

final class ReportVM: ViewModelBase {
    
    private let sceneCoordinator: SceneCoordinator
    private let apiType:  ReportProtocol.Type
    
    let kind: ReportKind
    let id: String
    let reasons: [ReportReason]
    let selectedSubject: PublishSubject<Int>

    init(kind: ReportKind, id: String, sceneCoordinator: SceneCoordinator, apiType: ReportProtocol.Type = ReportDM.self) {
        
        self.kind = kind
        
        switch kind {
        case .recipe:
            reasons = [.harrasmentAndCyberbullying, .privacy, .impersonation, .violent, .childEndangerment, .hateSpeech, .spamAndScams, .others]
       
        case .comment:
            reasons = [.harrasmentAndCyberbullying, .privacy, .impersonation, .violent, .childEndangerment, .hateSpeech, .spamAndScams, .others]
            
        case .post:
            
            reasons = [.harrasmentAndCyberbullying, .privacy, .impersonation, .violent, .childEndangerment, .hateSpeech, .spamAndScams, .others]
        }
        
        self.sceneCoordinator = sceneCoordinator
        self.selectedSubject = PublishSubject<Int>()
        self.id = id
        self.apiType = apiType
        
    }
    
    
    func report(row: Int) -> Observable<Bool> {
        
        return self.apiType.report(kind: kind, contentID: id, reason: reasons[row])
        
    }
    
    func userDismissed() {
        
        self.sceneCoordinator.userDismissed()
        
    }
    
    
}
