//
//  TimeLineVM.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-28.
//

import Foundation
import Firebase
import RxSwift

class TimelineVM {
    
    let user: Firebase.User
    let apiType: MainDMProtocol.Type
    var posts:[Timeline]
    
    init(user: Firebase.User, apiType: MainDMProtocol.Type = MainDM.self) {
        
        self.user = user
        self.apiType = apiType
        self.posts = []
     
    }
    
//    func getMyTimeline() -> Observable<Timeline> {
//        
//    }
    
}
