//
//  FestivalAPIService.swift
//  FestivalTogether
//
//  Created by SIKim on 9/28/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Alamofire


///축제 기본 정보 서비스
class FestivalAPIService {
    static let shared = FestivalAPIService()
    
    private let dateFormatter = DateFormatter()
    
    private init() { }
    
    ///API를 통해 json형식의 데이터를 받아옴
    func fetchFestivalData() -> Observable<Data> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            self.dateFormatter.dateFormat = "yyyyMMdd"
            self.dateFormatter.locale = Locale(identifier: "ko_kr")
            self.dateFormatter.timeZone = TimeZone(abbreviation: "KST")
            
            let urlString = "https://apis.data.go.kr/B551011/KorService1/searchFestival1"
            let parameters: Parameters = [
                "numOfRows" : 1000,
                "MobileOS" : "IOS",
                "MobileApp" : "Festimeet",
                "_type" : "json",
                "eventStartDate" : self.dateFormatter.string(from: Date()),
                "serviceKey" : festivalServiceKey
            ]
            
            AF.request(urlString,
                       method: .get,
                       parameters: parameters,
                       encoding: URLEncoding.default,
                       headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .response { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { return }
                    if let _ = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        emitter.onNext(data)
                        emitter.onCompleted()
                    } else {
                        emitter.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid JSON format"]))
                    }
                case .failure(let error):
                    emitter.onError(error)
                    break
                }
            }
            return Disposables.create()
        }
        .retry(5)
    }
}
