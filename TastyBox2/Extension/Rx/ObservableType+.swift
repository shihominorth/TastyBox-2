//
//  ObservableType+.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-09-20.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func flatMap<O>(withLock: ActivityIndicator, _ selector: @escaping (Self.Element) throws -> O) -> RxSwift.Observable<O.Element> where O : ObservableConvertibleType {
        return self
            .withLatestFrom(withLock) { input, loading in
                return (input, loading)
            }
            .filter { (input, loading) in
                return !loading
            }
            .flatMap({ (input, loading) -> RxSwift.Observable<O.Element> in
                return (try! selector(input)).trackActivity(withLock)
            })
    }
    
    public func takeNoCompleted(_ count: Int) -> Observable<Element> {
           return .concat(take(count), .never())
           // 略さず書くとこんな感じ
           // return Observable.concat(self.take(count), Observable.never())
       }


}

