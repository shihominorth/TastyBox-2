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

enum ReportKind {
    case recipe, comment, post
}

class ReportVM: ViewModelBase {
    
    let kind: ReportKind
    let id: String
    let reasons: [ReportReason]
    let selectedSubject: PublishSubject<Int>
    
    
    init(kind: ReportKind, id: String, sceneCoordinator: SceneCoordinator) {
        
        self.kind = kind
        
        switch kind {
        case .recipe:
            reasons = [.harrasmentAndCyberbullying, .privacy, .impersonation, .violent, .childEndangerment, .hateSpeech, .spamAndScams, .others]
       
        case .comment:
            reasons = [.harrasmentAndCyberbullying, .privacy, .impersonation, .violent, .childEndangerment, .hateSpeech, .spamAndScams, .others]
            
        case .post:
            
            reasons = [.harrasmentAndCyberbullying, .privacy, .impersonation, .violent, .childEndangerment, .hateSpeech, .spamAndScams, .others]
        }
        
        self.selectedSubject = PublishSubject<Int>()
        self.id = id
        
    }
    
    
    
}
