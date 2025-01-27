//
//  MyPostViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/25/24.
//

import Foundation
import RxSwift
import RxCocoa

class MyPostViewModel {
    private let disposeBag = DisposeBag()
    var currentPostCount = 0
    
    ///내가 쓴 글 Array Subject
    var myPostSubject = BehaviorSubject<[Post]>(value: [])
    
    init() {
        //내가 쓴 글 첫 페이지 패치
        FirebaseFirestoreService.shared.getFirstPageMyPostData()
            .subscribe(onNext: { [weak self] in
                self?.currentPostCount = $0.count
                self?.myPostSubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///내가 쓴 글 다음 페이지 로드
    func loadPagePost() {
        FirebaseFirestoreService.shared.getPageMyPostData()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                do {
                    var tempPost = try self.myPostSubject.value()
                    tempPost.append(contentsOf: $0)
                    self.currentPostCount = tempPost.count
                    self.myPostSubject.onNext(tempPost)
                } catch {
                    print("MyPost Data Loading Error")
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
