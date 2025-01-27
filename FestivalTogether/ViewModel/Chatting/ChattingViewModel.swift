//
//  ChattingViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 11/5/24.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class ChattingViewModel {
    private var tempMessages: [Message] = []
    var newMessageCount = 0
    let pageSize = 20
    var pageCount = 1
    
    private let disposeBag = DisposeBag()
    ///채팅 Id Subject
    var chattingIdSubject = BehaviorSubject<String?>(value: nil)
    ///메시지 텍스트 Subject
    var messageTextSubject = BehaviorSubject<String?>(value: nil)
    ///채팅 Subject
    var chattingSubject = BehaviorSubject<Chatting>(value: Chatting(id: "", chattingName: "", memberIds: [], members: []))
    ///메시지 Array Subject
    var messagesSubject = BehaviorSubject<[Message]>(value: [])
    ///채팅 Id, 메시지 텍스트 Combine Observable
    lazy var sendMessageObservable = Observable
        .combineLatest(chattingIdSubject, messageTextSubject)
    
    ///기존 채팅방이 있으면 읽어옴
    func loadExistChatting(otherId: String) {
        Task {
            guard let userId = UserDefaults.standard.string(forKey: "UserID") else { return }
            guard let chattingId = await FirebaseFirestoreService.shared.checkChattingData(userId: userId, otherId: otherId) else { return }
            fetchChatting(chattingId: chattingId)
        }
    }
    
    ///채팅방 나가기
    func exitChatting() {
        chattingIdSubject
            .take(1)
            .subscribe(onNext: { [weak self] in
                guard let chattingId = $0 else { return }
                guard let userId = UserDefaults.standard.string(forKey: "UserID") else { return }
                //렐름에 저장된 채팅 데이터 삭제
                let realm = try! Realm()
                let realmObject = realm.objects(ChattingForRealm.self)
                    .filter("id == %@", chattingId)
                try! realm.write {
                    realm.delete(realmObject)
                }
                
                //Firestore 데이터 삭제, Push Notification 구독 해제
                Task {
                    await FirebaseFirestoreService.shared.removeChattingMember(chattingId: chattingId, memberId: userId)
                    FirebaseCloudMessagingService.shared.chattingMessageUnsubscribe(topics: [chattingId])
                    self?.chattingIdSubject.onNext("exit")
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///채팅 메시지 패치
    func fetchChatting(chattingId: String) {
        //렐름에 저장된 메시지 데이터 페이지 크기만큼 읽어옴
        let realm = try! Realm()
        
        let messagesFromRealm = realm.objects(ChattingForRealm.self)
            .filter("id == %@", chattingId)
            .sorted(byKeyPath: "senderDate", ascending: false)
            .prefix(pageSize)
        
        if !messagesFromRealm.isEmpty {
            for message in messagesFromRealm {
                tempMessages.append(Message(senderId: message.senderId, senderDate: message.senderDate, senderMessage: message.senderMessage))
            }
        }
        
        chattingIdSubject.onNext(chattingId)
        
        //채팅 패치
        FirebaseFirestoreService.shared.getChattingData(chattingId: chattingId)
            .subscribe(onNext: { [weak self] in
                self?.chattingSubject.onNext($0)
            })
            .disposed(by: disposeBag)
        
        //메시지 패치
        FirebaseFirestoreService.shared.getMessageData(chattingId: chattingId)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if !$0.isEmpty {
                    let realmInTask = try! Realm()
                    
                    let messagesForRealm: [ChattingForRealm] = $0.map { ChattingForRealm(id: chattingId, senderId: $0.senderId, senderDate: $0.senderDate, senderMessage: $0.senderMessage)}
                    let messagesList = List<ChattingForRealm>()
                    messagesList.append(objectsIn: messagesForRealm)
                    
                    try! realmInTask.write {
                        realmInTask.add(messagesList)
                    }
                    
                    newMessageCount += $0.count
                    self.tempMessages.append(contentsOf: $0)
                }
                self.messagesSubject.onNext(self.tempMessages)
            })
            .disposed(by: disposeBag)
    }
    
    ///이전 메시지 읽어옴 ( Pagination )
    func loadPastMessage() {
        chattingIdSubject
            .take(1)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let realm = try! Realm()
                
                let messagesFromRealm = realm.objects(ChattingForRealm.self)
                    .filter("id == %@", $0 ?? "")
                    .sorted(byKeyPath: "senderDate", ascending: false)
                    .dropFirst(newMessageCount + (self.pageSize * self.pageCount))
                    .prefix(self.pageSize)
                
                if !messagesFromRealm.isEmpty {
                    for message in messagesFromRealm {
                        tempMessages.append(Message(senderId: message.senderId, senderDate: message.senderDate, senderMessage: message.senderMessage))
                    }
                }
                pageCount += 1
                
                messagesSubject.onNext(tempMessages)
            })
            .disposed(by: disposeBag)
    }
    
    ///메시지 전송
    func sendMessage(otherId: String?) {
        guard let currentUser = try? FirebaseFirestoreService.shared.currentUserSubject.value() else { return }
        do {
            //채팅방이 없을 경우 생성 후 메시지 전송, 아닌 경우 메시지 전송
            if try self.chattingIdSubject.value() == nil {
                messageTextSubject
                    .take(1)
                    .subscribe(onNext: { [weak self] message in
                        Task { [weak self] in
                            guard let self else { return }
                            guard let otherId else { return }
                            let chattingId = UUID().uuidString
                            //채팅 데이터 생성, 저장, Push Notification 전송
                            await FirebaseFirestoreService.shared.setChattingMessageData(chatting: Chatting(id: chattingId, chattingName: "\(currentUser.nickname)", lastMessage: message, lastMessageDate: Date(), memberIds: [currentUser.id, otherId], members: [Member(userId: currentUser.id, nickname: currentUser.nickname, profileImageURLString: currentUser.profileImageURLString, startDate: Date(), lastReadDate: Date())]), message: Message(senderId: currentUser.id, senderDate: Date(), senderMessage: message ?? ""))
                            FirebaseCloudMessagingService.shared.sendPushNotificationAboutStartChatting(otherId: otherId, title: currentUser.nickname, body: "채팅방에 초대되었어요!")
                            self.fetchChatting(chattingId: chattingId)
                        }
                    })
                    .disposed(by: disposeBag)
            } else {
                sendMessageObservable
                    .take(1)
                    .subscribe(onNext: { chattingId, messageText in
                        //메시지 데이터 업데이트 및 Push Notification 전송
                        FirebaseFirestoreService.shared.updateChattingMessageData(chattingId: chattingId ?? "", message: Message(senderId: currentUser.id, senderDate: Date(), senderMessage: messageText ?? ""))
                        FirebaseCloudMessagingService.shared.sendPushNotificationAboutAfterChatting(topic: chattingId ?? "", title: currentUser.nickname, body: messageText ?? "")
                    })
                    .disposed(by: disposeBag)
            }
        } catch {
            print("Error : \(error)")
        }
    }
    
    ///사용자 신고
    func reportUser(userId: String) -> Observable<Bool> {
        FirebaseFirestoreService.shared.setUserReport(userId: userId)
    }
    
    ///마지막으로 읽은 날짜 업데이트
    func updateLastReadDate() {
        chattingIdSubject
            .filter { $0 != nil }
            .subscribe(onNext: {
                FirebaseFirestoreService.shared.updateLastReadDate(chattingId: $0!)
            })
            .disposed(by: disposeBag)
    }
    
    ///보낸사람 닉네임 String
    func senderNickname(otherId: String) -> String {
        var nickname = ""
        
        try? chattingSubject.value().members.forEach { member in
            if member.userId == otherId {
                nickname = member.nickname
            }
        }
        return nickname
    }
    
    ///보낸사람 프로필 이미지 URL String
    func senderProfileImageURLString(otherId: String) -> String? {
        var profileImageURLString: String?
        
        try? chattingSubject.value().members.forEach { member in
            if member.userId == otherId {
                profileImageURLString = member.profileImageURLString
            }
        }
        return profileImageURLString
    }
    
    ///날짜 변환 String
    func dateConvert(date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM월 dd일 HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dateFormatter.string(from: date)
    }
}
