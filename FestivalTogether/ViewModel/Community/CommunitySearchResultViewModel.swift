//
//  CommunitySearchResultViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/22/24.
//

import Foundation
import RxSwift
import RxCocoa

class CommunitySearchResultViewModel {
    private let disposeBag = DisposeBag()
    var currentPostCount = 0
    ///검색 결과 게시글 Array Subject
    let searchedPostSubject = BehaviorSubject<[Post]>(value: [])
    
    ///검색 결과 게시글 패치
    func fetchSearchPost(searchText: String) {
        FirebaseFirestoreService.shared.getFirstPageSearchPostData(searchText: searchText)
            .subscribe(onNext: { [weak self] in
                self?.searchedPostSubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///다음 페이지 게시글 읽어옴
    func loadPageSearchPost(searchText: String) {
        FirebaseFirestoreService.shared.getPageSearchPostData(searchText: searchText)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                do {
                    var tempPost = try self.searchedPostSubject.value()
                    tempPost.append(contentsOf: $0)
                    self.currentPostCount = tempPost.count
                    self.searchedPostSubject.onNext(tempPost)
                } catch {
                    print("Post Data Loading Error")
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///날짜 변환 String
    func dateConvert(date: Date) -> String {
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
