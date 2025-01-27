//
//  FestivalDetailAPIService.swift
//  FestivalTogether
//
//  Created by SIKim on 10/2/24.
//

import Foundation
import Alamofire
import RxSwift

///자세한 축제 내용 서비스
class FestivalDetailAPIService {
    
    ///API를 통해 json형식의 데이터를 받아옴
    func fetchFestivalDetailData(contentId: String) -> Observable<Data> {
        return Observable.create() { emitter in
            let urlString = "https://apis.data.go.kr/B551011/KorService1/detailCommon1"
            let parameters: Parameters = [
                "MobileOS" : "IOS",
                "MobileApp" : "Festimeet",
                "_type" : "json",
                "contentId" : contentId,
                "defaultYN" : "Y",
                "firstImageYN" : "Y",
                "addrinfoYN" : "Y",
                "mapinfoYN" : "Y",
                "overviewYN" : "Y",
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
        .share(replay: 1, scope: .forever)
    }
}
