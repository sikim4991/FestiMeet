//
//  CommunityViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/9/24.
//

import Foundation
import RxCocoa
import RxSwift
import RealmSwift
import FirebaseMessaging

class CommunityViewModel {
    private let disposeBag = DisposeBag()
    var currentPostCount = 0
    ///게시글 Array Subject
    let postSubject = BehaviorSubject<[Post]>(value: [])
    
    ///로그인 확인 Observable
    lazy var isSignInObservable = FirebaseFirestoreService.shared.currentUserSubject
        .map {
            $0 != nil ? true : false
        }
    
    ///정지 계정 확인 Observable
    lazy var isCheckReportUserObservable = FirebaseFirestoreService.shared.currentUserSubject
        .filter { $0 != nil }
        .map {
            $0!.reportCount > 2 ? true : false
        }
    
    ///새 알림 확인 Observable
    lazy var isCheckLastNotificationObservable = FirebaseFirestoreService.shared.isCheckLastNotification()
    
    ///게시글 첫 페이지 패치
    func fetchFirstPagePost() {
        FirebaseFirestoreService.shared.getFirstPagePostData()
            .subscribe(onNext: { [weak self] in
                self?.currentPostCount = $0.count
                self?.postSubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///게시글 다음 페이지 읽어옴
    func loadPagePost() {
        FirebaseFirestoreService.shared.getPagePostData()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                do {
                    var tempPost = try self.postSubject.value()
                    tempPost.append(contentsOf: $0)
                    self.currentPostCount = tempPost.count
                    self.postSubject.onNext(tempPost)
                } catch {
                    print("Post Data Loading Error")
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///로그아웃
    func signOut() {
        let realm = try! Realm()
        
        //렐름 데이터 삭제
        try! realm.write {
            realm.deleteAll()
        }
        
        //토큰 및 User에 대한 정보 리셋
        Task {
            do {
                try await Messaging.messaging().deleteToken()
                FirebaseFirestoreService.shared.currentUserSubject.onNext(nil)
                UserDefaults.standard.set(nil, forKey: "UserID")
            } catch {
                print("Messaging deleteToken error")
            }
        }
    }
    
    ///게시글 날짜 변환 String
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
