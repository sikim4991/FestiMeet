//
//  FestivalSearchViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/3/24.
//

import Foundation
import RxSwift
import Alamofire

class FestivalSearchViewModel {
    private let disposeBag = DisposeBag()
    ///검색어 텍스트 Subject
    var searchTextSubject = BehaviorSubject<String>(value: "")
    ///축제 Array Subject
    var festivalSubject = BehaviorSubject<[FestivalItem]>(value: [])
    
    ///검색어 결과 Array Observable
    lazy var searchResultsObservable = Observable
        .combineLatest(searchTextSubject, festivalSubject)
        .map { searchText, festivals in
            if searchText != "" {
                var filteredFestivals: [FestivalItem] = festivals.filter { $0.title.lowercased().contains(searchText.lowercased()) }
                return Array(filteredFestivals.prefix(20))
            } else {
                return Array(festivals.prefix(20))
            }
        }
    
    init() {
        //축제 데이터 패치
        FestivalAPIService.shared.fetchFestivalData()
            .map { data -> FestivalJSON in
                do {
                    let json = try JSONDecoder().decode(FestivalJSON.self, from: data)
                    return json
                } catch {
                    print("JSON Decoding Error: \(error.localizedDescription)")
                    return FestivalJSON(response: FestivalResponse(header: FestivalHeader(resultCode: "Error", resultMsg: "Error"), body: FestivalBody(items: FestivalItems(item: []), numOfRows: 0, pageNo: 0, totalCount: 0)))
                }
            }
            .map { json -> [FestivalItem] in
                return json.response.body.items.item.sorted(by: {
                    Int($0.eventenddate)! <= Int($1.eventenddate)!
                })
            }
            .subscribe(onNext: { [weak self] in
                self?.festivalSubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///검색어 텍스트 패치
    func setSearchText(text: String) {
        searchTextSubject.onNext(text)
    }
}
