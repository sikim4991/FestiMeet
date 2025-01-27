//
//  FestivalListViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 9/28/24.
//

import Foundation
import RxSwift
import RxCocoa

class FestivalListViewModel {
    var allItemsCount = 0
    var currentItemsCount = 0
    var currentPage = 1
    
    private let disposeBag = DisposeBag()
    private let areaCodeAPIService = AreaCodeAPIService()
    ///지역 코드 Array Subject
    var allAreaCodeSubject = BehaviorSubject<[AreaCodeItem]>(value: [])
    ///선택한 지역 코드 Subject
    var areaCodeForFilterSubject = BehaviorSubject<AreaCodeItem>(value: AreaCodeItem(rnum: 0, code: nil, name: "전국"))
    ///선택한 날짜 Subject
    var dateForFilterSubject = BehaviorSubject<Date>(value: Date())
    ///현재 페이지 Subject
    var currentPageSubject = BehaviorSubject<Int>(value: 1)
    ///모든 축제 Array Subject
    var allFestivalSubject = BehaviorSubject<[FestivalItem]>(value: [])
    ///필터를 거친 결과의 축제 Array Observable
    lazy var festivalForPaginationObservable = Observable
        .combineLatest(allFestivalSubject, currentPageSubject, dateForFilterSubject, areaCodeForFilterSubject)
        //날짜와 지역 필터
        .map { items, page, date, areaCodeItem in
            let dateFormatter = DateFormatter()
            var dateStringForFilter = ""
            var filteredItems: [FestivalItem] = []
            
            dateFormatter.dateFormat = "yyyyMMdd"
            dateFormatter.locale = Locale(identifier: "ko_kr")
            dateFormatter.timeZone = TimeZone(abbreviation: "KST")
            
            dateStringForFilter = dateFormatter.string(from: date)
            filteredItems = items.filter { Int($0.eventstartdate)! <= Int(dateStringForFilter)! && Int($0.eventenddate)! >= Int(dateStringForFilter)! }
            filteredItems = filteredItems.filter {
                if let code = areaCodeItem.code {
                    return $0.areacode == code
                } else {
                    return true
                }
            }
            
            return (filteredItems, page)
        }
        //페이지 추가 (20개)
        .map { items, page in
            let maxItems = 20 * page
            self.currentItemsCount = Array(items.prefix(maxItems)).count
            // currentPage에 따라 배열의 최대 아이템 수 결정
            return Array(items.prefix(maxItems))
        }
    
    init() {
        //축제 데이터 패치
        FestivalAPIService.shared.fetchFestivalData()
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
            .subscribe(onNext: { [weak self] in
                self?.allFestivalSubject.onNext($0)
                self?.allItemsCount = $0.count
            })
            .disposed(by: disposeBag)
        
        //지역 코드 패치
        areaCodeAPIService.fetchAreaCodeData()
            .map {
                do {
                    let json = try JSONDecoder().decode(AreaCodeJSON.self, from: $0)
                    return json
                } catch {
                    print("JSON Decoding Error: \(error.localizedDescription)")
                    return AreaCodeJSON(response: AreaCodeResponse(header: AreaCodeHeader(resultCode: "", resultMsg: ""), body: AreaCodeBody(items: AreaCodeItems(item: []), numOfRows: 0, pageNo: 0, totalCount: 0)))
                }
            }
            .map {
                var newItems: [AreaCodeItem] = [AreaCodeItem(rnum: 0, code: nil, name: "전국")]
                
                $0.response.body.items.item.forEach({
                    newItems.append($0)
                })
                return newItems
            }
            .subscribe(onNext: { [weak self] in
                self?.allAreaCodeSubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///다음 페이지로 넘김 ( Page 증가 )
    func loadForPagination() {
        if currentItemsCount < allItemsCount {
            currentPage += 1
            currentPageSubject.onNext(currentPage)
        }
    }
    
    ///첫 페이지로 리셋
    func resetPagination() {
        currentPage = 1
        currentPageSubject.onNext(currentPage)
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
    
    ///선택한 날짜 패치
    func pickDateForFilter(date: Date) {
        dateForFilterSubject.onNext(date)
    }
}
