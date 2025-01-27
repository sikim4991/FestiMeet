//
//  MyReplyViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/26/24.
//

import Foundation
import RxSwift
import RxCocoa

class MyReplyViewModel {
    private let disposeBag = DisposeBag()
    var currentReplyCount = 0
    var currentReplyCommentCount = 0
    
    ///댓글, 대댓글 스위치 Subject
    var isReplySubject = BehaviorSubject<Bool>(value: true)
    ///나의 댓글 Array Subject
    var myReplySubject = BehaviorSubject<[Reply]>(value: [])
    ///나의 대댓글 Array Subject
    var myReplyCommentSubject = BehaviorSubject<[ReplyComment]>(value: [])
    
    ///댓글, 대댓글 없는지 확인 Observable
    lazy var isEmptyObservable = Observable
        .combineLatest(myReplySubject, myReplyCommentSubject)
        .map { myReply, myReplyComment in
            !myReply.isEmpty || !myReplyComment.isEmpty
        }
    
    init() {
        //나의 댓글 첫 페이지 패치
        FirebaseFirestoreService.shared.getFirstPageMyReplyData()
            .subscribe(onNext: { [weak self] in
                self?.currentReplyCount = $0.count
                self?.myReplySubject.onNext($0)
            })
            .disposed(by: disposeBag)
        
        //나의 대댓글 첫 페이지 패치
        FirebaseFirestoreService.shared.getFirstPageMyReplyCommentData()
            .subscribe(onNext: { [weak self] in
                self?.currentReplyCommentCount = $0.count
                self?.myReplyCommentSubject.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    ///나의 댓글 다음 페이지 패치
    func loadPageReply() {
        FirebaseFirestoreService.shared.getPageMyReplyData()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                do {
                    var tempReply = try self.myReplySubject.value()
                    tempReply.append(contentsOf: $0)
                    self.currentReplyCount = tempReply.count
                    self.myReplySubject.onNext(tempReply)
                } catch {
                    print("MyReply Data Loading Error")
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///나의 대댓글 다음 페이지 패치
    func loadPageReplyComment() {
        FirebaseFirestoreService.shared.getPageMyReplyCommentData()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                do {
                    var tempReplyComment = try self.myReplyCommentSubject.value()
                    tempReplyComment.append(contentsOf: $0)
                    self.currentReplyCommentCount = tempReplyComment.count
                    self.myReplyCommentSubject.onNext(tempReplyComment)
                } catch {
                    print("MyReply Data Loading Error")
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///선택한 댓글, 대댓글 게시글 읽어옴
    func loadSelectedPost(postId: String, completion: @escaping (Post?) -> Void) {
        FirebaseFirestoreService.shared.getSelectedPostData(postId: postId)
            .subscribe(onNext: { post in
                completion(post)
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
