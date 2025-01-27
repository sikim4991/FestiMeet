//
//  FestivalSearchResultViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/3/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class FestivalSearchResultViewModel {
    private let disposeBag = DisposeBag()
    ///검색어 텍스트
    var searchText: String
    ///검색에 일치하는 축제 Array Observable
    lazy var filteredFestivalsObservable = FestivalAPIService.shared.fetchFestivalData()
        .map { data -> FestivalJSON in
            do {
                let json = try JSONDecoder().decode(FestivalJSON.self, from: data)
                return json
            } catch {
                print("JSON Decoding Error: \(error.localizedDescription)")
                return FestivalJSON(response: FestivalResponse(header: FestivalHeader(resultCode: "Error", resultMsg: "Error"), body: FestivalBody(items: FestivalItems(item: []), numOfRows: 0, pageNo: 0, totalCount: 0)))
            }
        }
        .map {
            return $0.response.body.items.item.sorted(by: {
                Int($0.eventenddate)! <= Int($1.eventenddate)!
            })
        }
        .map { [weak self] in
            guard let self else { return $0 }
            return $0.filter { $0.title.lowercased().contains(self.searchText.lowercased()) }
        }
    
    init(searchText: String) {
        self.searchText = searchText
    }
    
    ///축제 날짜 변환 String
    func dateConvert(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        let convertDateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        convertDateFormatter.dateFormat = "yyyy년 M월 d일 (E)"
        convertDateFormatter.locale = Locale(identifier: "ko_kr")
        convertDateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        var convertDateString = ""
        guard let convertDate = dateFormatter.date(from: dateString) else { return "날짜 오류"}
        
        convertDateString = convertDateFormatter.string(from: convertDate)
        
        return convertDateString
    }
}
