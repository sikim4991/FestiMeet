//
//  HomeViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 9/23/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class HomeViewModel {
    private let disposeBag = DisposeBag()
    
    ///곧 끝나는 축제 5개 Array Observable
    lazy var festivalsObservable = FestivalAPIService.shared.fetchFestivalData()
        .map {
            do {
                let json = try JSONDecoder().decode(FestivalJSON.self, from: $0)
                return json
            } catch {
                print("JSON Decoding Error: \(error.localizedDescription)")
                return FestivalJSON(response: FestivalResponse(header: FestivalHeader(resultCode: "Error", resultMsg: "Error"), body: FestivalBody(items: FestivalItems(item: []), numOfRows: 0, pageNo: 0, totalCount: 0)))
            }
        }
        .map {
            $0.response.body.items.item.sorted(by: {
                Int($0.eventenddate)! <= Int($1.eventenddate)!
            })
        }
        .map {
            Array($0.prefix(5))
        }
    
    ///최신순 게시글 3개 Array Observable
    lazy var communityObservable = FirebaseFirestoreService.shared.getMainPostData()
    
    ///포스터 축제 날짜 변환 String
    func posterDateConvert(startDateString: String, endDateString: String) -> String {
        let dateFormatter = DateFormatter()
        let convertDateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        convertDateFormatter.dateFormat = "yyyy년 M월 d일 (E)"
        convertDateFormatter.locale = Locale(identifier: "ko_kr")
        convertDateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        if startDateString == endDateString {
            guard let convertDate = dateFormatter.date(from: startDateString) else { return "날짜 오류"}
            return convertDateFormatter.string(from: convertDate)
        } else {
            var convertStartDateString = ""
            var convertEndDateString = ""
            guard let convertStartDate = dateFormatter.date(from: startDateString) else { return "날짜 오류"}
            guard let convertEndDate = dateFormatter.date(from: endDateString) else { return "날짜 오류"}
            
            convertStartDateString = convertDateFormatter.string(from: convertStartDate)
            convertEndDateString = convertDateFormatter.string(from: convertEndDate)
            
            return "\(convertStartDateString) - \(convertEndDateString)"
        }
    }
    
    ///포스터 지역 변환 String
    func posterLocationConvert(location: String) -> String {
        let stringArray = location.split(separator: " ")
        var posterLocation = ""
        
        for (index, string) in stringArray.enumerated() {
            if index < 2 {
                posterLocation += string
            } else {
                break
            }
            posterLocation += " "
        }
        
        return posterLocation != "" ? posterLocation : "?"
    }
    
    ///게시글 날짜 변환 String
    func posterCommunityDateConvert(date: Date) -> String {
        var current = Calendar.current
        let todayDateFormatter = DateFormatter()
        let pastDateFormatter = DateFormatter()
        
        todayDateFormatter.dateFormat = "HH:mm"
        todayDateFormatter.locale = Locale(identifier: "ko_kr")
        todayDateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        pastDateFormatter.dateFormat = "MM/dd"
        pastDateFormatter.locale = Locale(identifier: "ko_kr")
        pastDateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        current.locale = Locale(identifier: "ko_kr")
        current.timeZone = TimeZone(abbreviation: "KST") ?? .current
        
        if current.isDateInToday(date) {
            return todayDateFormatter.string(from: date)
        } else {
            return pastDateFormatter.string(from: date)
        }
    }
}
