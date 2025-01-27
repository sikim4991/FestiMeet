//
//  CommunityDetailViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class CommunityDetailViewModel {
    private let disposeBag = DisposeBag()
    ///댓글 입력 String Subject
    var replyStringSubject = BehaviorSubject<String?>(value: nil)
    ///댓글 Array Subject
    var replySubject = BehaviorSubject<[Reply]?>(value: nil)
    ///대댓글 Array Subject
    var replyCommentSubject = BehaviorSubject<[ReplyComment]?>(value: nil)
    ///댓글 수 Observable
    lazy var replyCountObservable = Observable
        .combineLatest(replySubject, replyCommentSubject)
        .map { replies, replyComments in
            guard let replies else { return 0 }
            guard let replyComments else { return 0 }
            
            return replies.count + replyComments.count
        }
    
    ///댓글 섹션 Observable
    lazy var replySectionObservable = Observable
        .combineLatest(replySubject, replyCommentSubject)
        .filter({ replies, replyComments in
            if let replies, let replyComments {
                return true
            } else {
                return false
            }
        })
        .map { [weak self] replies, replyComments in
            var sections: [ReplySection] = [ReplySection(header: Reply(id: "", postId: "", userId: "", nickname: "", createdDate: Date(), detail: "", reportCount: 0, reporterIds: []), items: [ReplyComment(id: "", postId: "", replyId: "", userId: "", nickname: "", createdDate: Date(), detail: "", reportCount: 0, reporterIds: [])])]
            guard let replies else { return sections }
            guard let replyComments else { return sections }
            
            replies.forEach { reply in
                sections.append(ReplySection(header: reply, items: []))
            }
            
            for replyComment in replyComments {
                for (index, section) in sections.enumerated() {
                    if section.header.id == replyComment.replyId {
                        sections[index].items.append(replyComment)
                    }
                }
            }
            
            return sections
        }
    
    ///댓글 업로드
    func uploadReply(post: Post) {
        do {
            let currentUser = try FirebaseFirestoreService.shared.currentUserSubject.value()
            guard let currentUser else { return }
            replyStringSubject
                .take(1)
                .compactMap { $0 }
                .subscribe(onNext: {
                    FirebaseFirestoreService.shared.setReplyData(reply: Reply(id: UUID().uuidString, postId: post.id, userId: currentUser.id , nickname: currentUser.nickname, createdDate: Date(), detail: $0, reportCount: 0, reporterIds: []))
                    FirebaseCloudMessagingService.shared.sendPushNotificationAboutPost(post: post, body: $0)
                })
                .disposed(by: disposeBag)
        } catch {
            print(error)
        }
    }
    
    ///댓글 패치
    func fetchReply(postId: String) {
        FirebaseFirestoreService.shared.getReplyData(postId: postId)
            .subscribe(onNext: { [weak self] in
                self?.replySubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///뎃글 삭제
    func removeReply(reply: Reply) async {
        await FirebaseFirestoreService.shared.removeReplyData(reply: reply)
    }
    
    ///댓글 신고
    func reportReply(replyId: String) -> Observable<Bool> {
        FirebaseFirestoreService.shared.updateReplyReport(replyId: replyId)
    }
    
    ///대댓글 업로드
    func uploadReplyComment(post: Post, replyId: String) {
        do {
            let currentUser = try FirebaseFirestoreService.shared.currentUserSubject.value()
            guard let currentUser else { return }
            replyStringSubject
                .take(1)
                .compactMap { $0 }
                .subscribe(onNext: {
                    FirebaseFirestoreService.shared.setReplyCommentData(replyComment: ReplyComment(id: UUID().uuidString, postId: post.id, replyId: replyId, userId: currentUser.id, nickname: currentUser.nickname, createdDate: Date(), detail: $0, reportCount: 0, reporterIds: []))
                    FirebaseCloudMessagingService.shared.sendPushNotificationAboutReply(replyId: replyId, post: post, body: $0)
                })
                .disposed(by: disposeBag)
        } catch {
            print(error)
        }
    }
    
    ///대댓글 패치
    func fetchReplyComment(postId: String) {
        FirebaseFirestoreService.shared.getReplyCommentData(postId: postId)
            .subscribe(onNext: { [weak self] in
                self?.replyCommentSubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///대댓글 삭제
    func removeReplyComment(replyComment: ReplyComment) {
        FirebaseFirestoreService.shared.removeReplyCommentData(replyComment: replyComment)
    }
    
    ///대댓글 신고
    func reportReplyComment(replyCommentId: String) -> Observable<Bool> {
        FirebaseFirestoreService.shared.updateReplyCommentReport(replyCommentId: replyCommentId)
    }
    
    ///게시글 삭제
    func removePost(postId: String) async {
        await FirebaseFirestoreService.shared.removePostData(postId: postId)
    }
    
    ///게시글 신고
    func reportPost(postId: String) -> Observable<Bool> {
        FirebaseFirestoreService.shared.updatePostReport(postId: postId)
    }
    
    ///날짜 변환 String
    func convertDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dateFormatter.string(from: date)
    }
}
