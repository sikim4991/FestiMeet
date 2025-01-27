//
//  FestivalDetailViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/1/24.
//

import Foundation
import RxSwift
import RxCocoa
import NMapsMap

class FestivalDetailViewModel {
    private let disposeBag = DisposeBag()
    private let festivalIntroAPIService = FestivalIntroAPIService()
    private let festivalImageAPIService = FestivalImageAPIService()
    private let festivalDetailAPIService = FestivalDetailAPIService()
    
    ///축제 Id
    var contentId: String
    
    ///축제 이미지 URL String Array Observable
    lazy var urlStringsObservable = festivalImageAPIService.fetchImageData(contentId: contentId)
        .map {
            do {
                let json = try JSONDecoder().decode(FestivalImageJSON.self, from: $0)
                return json
            } catch {
                print("festivalImageAPIService JSON Decoding Error: \(error.localizedDescription)")
                return FestivalImageJSON(response: FestivalImageResponse(header: FestivalImageHeader(resultCode: "", resultMsg: ""), body: FestivalImageBody(items: FestivalImageItems(item: []), numOfRows: 0, pageNo: 0, totalCount: 0)))
            }
        }
        .map {
            var convertItems: [String] = []
            
            $0.response.body.items.item.forEach { item in
                convertItems.append(item.originimgurl)
            }
            
            return convertItems
        }
    
    ///축제 상세 Observable
    lazy var festivalDetailObservable = festivalDetailAPIService.fetchFestivalDetailData(contentId: contentId)
        .map {
            do {
                let json = try JSONDecoder().decode(FestivalDetailJSON.self, from: $0)
                return json
            } catch {
                print("festivalDetailAPIService JSON Decoding Error: \(error.localizedDescription)")
                return FestivalDetailJSON(response: FestivalDetailResponse(header: FestivalDetailHeader(resultCode: "", resultMsg: ""), body: FestivalDetailBody(items: FestivalDetailItems(item: []), numOfRows: 0, pageNo: 0, totalCount: 0)))
            }
        }
        .map {
            return $0.response.body.items.item.first
        }
    
    ///축제 소개 Observable
    lazy var festivalIntroObservable = festivalIntroAPIService.fetchFestivalIntroData(contentId: contentId)
        .map {
            do {
                let json = try JSONDecoder().decode(FestivalIntroJSON.self, from: $0)
                return json
            } catch {
                print("festivalIntroAPIService JSON Decoding Error: \(error.localizedDescription)")
                return FestivalIntroJSON(response: FestivalIntroResponse(header: FestivalIntroHeader(resultCode: "", resultMsg: ""), body: FestivalIntroBody(items: FestivalIntroItems(item: []), numOfRows: 0, pageNo: 0, totalCount: 0)))
            }
        }
        .map {
            return $0.response.body.items.item.first
        }
    
    ///이미지 URL String Array Observable이 없을 경우 대처하는 Array Observable
    lazy var imageURLStringsObservable = Observable
        .combineLatest(urlStringsObservable, festivalDetailObservable)
        .map { urlStrings, detail in
            if urlStrings.isEmpty {
                return Array(arrayLiteral: detail?.firstimage ?? "")
            } else {
                return urlStrings
            }
        }
    
    ///축제 이름 Observable
    lazy var titleObservable = festivalDetailObservable
        .map {
            guard let title = $0?.title else { return "-" }
            return title == "" ? "-" : String(htmlEncodedString: title) ?? "-"
        }
    
    ///축제 날짜 Observable
    lazy var dateStringObservable = festivalIntroObservable
        .compactMap {
            let dateFormatter = DateFormatter()
            let convertDateFormatter = DateFormatter()
            var dateString = ""
            
            dateFormatter.dateFormat = "yyyyMMdd"
            dateFormatter.locale = Locale(identifier: "ko_kr")
            dateFormatter.timeZone = TimeZone(abbreviation: "KST")
            
            convertDateFormatter.dateFormat = "yyyy년 M월 d일"
            convertDateFormatter.locale = Locale(identifier: "ko_kr")
            convertDateFormatter.timeZone = TimeZone(abbreviation: "KST")
            
            if $0?.eventstartdate == $0?.eventenddate {
                dateString = "\(convertDateFormatter.string(from: dateFormatter.date(from: $0?.eventenddate ?? "")!))"
            } else {
                dateString = "\(convertDateFormatter.string(from: dateFormatter.date(from: $0?.eventstartdate ?? "")!)) - \(convertDateFormatter.string(from: dateFormatter.date(from: $0?.eventenddate ?? "")!))"
            }
            return dateString
        }
    
    ///축제 시간 Observable
    lazy var timeStringObservable = festivalIntroObservable
        .map {
            guard let playtime = $0?.playtime else { return "-" }
            return playtime == "" ? "-" : String(htmlEncodedString: playtime) ?? "-"
        }
    
    ///축제 주소 Observable
    lazy var addressObservable = Observable
        .combineLatest(festivalDetailObservable, festivalIntroObservable)
        .map { detail, intro in
            guard let detail, let intro else { return "-" }
            return String(htmlEncodedString: "\(detail.addr1) \(detail.addr2) \(intro.eventplace)") ?? "-"
        }
    
    ///축제 입장비(참가비) Observable
    lazy var feeObservable = festivalIntroObservable
        .map {
            guard let fee = $0?.usetimefestival else { return "-" }
            return fee == "" ? "-" : String(htmlEncodedString: fee) ?? "-"
        }
    
    ///축제 문의연락처 Observable
    lazy var telObservable = festivalDetailObservable
        .map {
            guard let tel = $0?.tel else { return "-" }
            return tel == "" ? "-" : String(htmlEncodedString: tel) ?? "-"
        }
    
    ///축제 문의처 Observable
    lazy var telNameObservable = festivalDetailObservable
        .map {
            guard let telName = $0?.telname else { return "-" }
            return telName == "" ? "-" : String(htmlEncodedString: telName) ?? "-"
        }
    
    ///축제 소개 내용 Observable
    lazy var introObservable = festivalDetailObservable
        .map {
            guard let overview = $0?.overview else { return "-" }
            return overview == "" ? "-" : String(htmlEncodedString: overview) ?? "-"
        }
    
    ///네이버 지도 축제 좌표 Observable
    lazy var mapxyObservable = festivalDetailObservable
        .map {
            NMGLatLng(lat: Double($0?.mapy ?? "0")!, lng: Double($0?.mapx ?? "0")!)
        }
    
    init(contentId: String) {
        self.contentId = contentId
    }
}
