//
//  AreaCodeAPIService.swift
//  FestivalTogether
//
//  Created by SIKim on 9/30/24.
//

import Foundation
import RxSwift
import Alamofire

///지역 코드 서비스
class AreaCodeAPIService {
    
    ///API를 통해 json형식의 데이터를 받아옴
    func fetchAreaCodeData() -> Observable<Data> {
        return Observable.create() { emitter in
            let urlString = "https://apis.data.go.kr/B551011/KorService1/areaCode1"
            let parameters: Parameters = [
                "numOfRows" : 1000,
                "MobileOS" : "IOS",
                "MobileApp" : "Festimeet",
                "_type" : "json",
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
