//
//  ChattingListViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 11/1/24.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import FirebaseMessaging

class ChattingListViewModel {
    ///addListener 수동 해제를 위한 Disposable
    private var disposable: Disposable?
    private let disposeBag = DisposeBag()
    ///채팅 리스트 Array Subject
    var chattingListSubject = BehaviorSubject<[Chatting]>(value: [])
    ///로그인 확인 Observable
    lazy var isSignInObservable = FirebaseFirestoreService.shared.currentUserSubject
        .map {
            $0 != nil ? true : false
        }
        .do(onNext: { [weak self] in
            if !$0 {
                self?.disposable?.dispose()
            }
        })
    
    ///정지 계정 확인 Observable
    lazy var isCheckReportUserObservable = FirebaseFirestoreService.shared.currentUserSubject
        .filter { $0 != nil }
        .map {
            $0!.reportCount > 2 ? true : false
        }
    
    init() {
        //현재 사용자의 채팅 리스트 패치
        FirebaseFirestoreService.shared.currentUserSubject
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                disposable = FirebaseFirestoreService.shared.getChattingInfoData()
                    .bind(to: chattingListSubject)
                
                disposable?.disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        //로그인 상태에 따라 채팅 Push Notification 구독/해제
        isSignInObservable
            .subscribe(onNext: { [weak self] isSignIn in
                guard let self else { return }
                disposable = FirebaseFirestoreService.shared.getChattingInfoData()
                    .filter { !$0.isEmpty }
                    .map {
                        var chattingIds: [String] = []
                        
                        $0.forEach { chatting in
                            chattingIds.append(chatting.id)
                        }
                        return chattingIds
                    }
                    .distinctUntilChanged()
                    .subscribe(onNext: {
                        //채팅 Id 구독/해제
                        if isSignIn {
                            FirebaseCloudMessagingService.shared.chattingMessageSubscribe(topics: $0)
                        } else {
                            FirebaseCloudMessagingService.shared.chattingMessageUnsubscribe(topics: $0)
                        }
                    })
                
                disposable?.disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    ///채팅 초대
    func inviteChatting(chattingId: String, member: Member) {
        do {
            //채팅 멤버 추가 및 Push Notification 전송
            guard let currentUser = try FirebaseFirestoreService.shared.currentUserSubject.value() else { return }
            FirebaseFirestoreService.shared.addChattingMember(chattingId: chattingId, member: member)
            FirebaseCloudMessagingService.shared.sendPushNotificationAboutStartChatting(otherId: member.userId, title: currentUser.nickname, body: "채팅방에 초대되었어요!")
        } catch {
            print("Invite Chatting Error : \(error)")
        }
    }
    
    ///로그아웃
    func signOut() {
        let realm = try! Realm()
        
        //렐름 데이터 삭제
        try! realm.write {
            realm.deleteAll()
        }
        Task {
            //토큰 및 User에 대한 정보 리셋
            do {
                try await Messaging.messaging().deleteToken()
                FirebaseFirestoreService.shared.currentUserSubject.onNext(nil)
                UserDefaults.standard.set(nil, forKey: "UserID")
            } catch {
                print("Messaging deleteToken error")
            }
        }
    }
    
    ///날짜 변환 String
    func dateConvert(date: Date) -> String {
        var current = Calendar.current
        let todayDateFormatter = DateFormatter()
        let pastDateFormatter = DateFormatter()
        
        todayDateFormatter.dateFormat = "HH:mm"
        todayDateFormatter.locale = Locale(identifier: "ko_kr")
        todayDateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        pastDateFormatter.dateFormat = "MM월 dd일"
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
