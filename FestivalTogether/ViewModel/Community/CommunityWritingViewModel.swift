//
//  CommunityWritingViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/10/24.
//

import Foundation
import RxSwift
import RxCocoa

class CommunityWritingViewModel {
    private let disposeBag = DisposeBag()
    
    ///생성 날짜 Observable
    let createdDateOb = Observable.just(Date())
    ///축제 이름 Subject
    let festivalTitleSubject = BehaviorSubject<String?>(value: nil)
    ///축제 Id Subject
    let festivalIdSubject = BehaviorSubject<String?>(value: nil)
    ///게시글 제목 Subject
    let titleSubject = BehaviorSubject<String?>(value: nil)
    ///게시글 내용 Subject
    let detailSubject = BehaviorSubject<String?>(value: nil)
    ///댓글 수 Subject
    let replyCountSubject = BehaviorSubject<Int>(value: 0)
    ///제목 유무 확인 Subject
    let isEmptyTitleSubject = BehaviorSubject<Bool>(value: false)
    ///내용 유무 확인 Subject
    let isEmptyDetailSubject = BehaviorSubject<Bool>(value: false)
    
    ///완료 버튼 활성화 Observable
    lazy var isEnableCompleteButtonObservable = Observable
        .combineLatest(isEmptyTitleSubject, isEmptyDetailSubject)
        .map { isEmptyTitle, isEmptyDetail in
            isEmptyTitle && isEmptyDetail
        }
    
    ///게시글 Observable
    lazy var postObservable = Observable
        .combineLatest(FirebaseFirestoreService.shared.currentUserSubject, createdDateOb, festivalTitleSubject, festivalIdSubject, titleSubject, detailSubject, replyCountSubject)
    
    ///게시글 업로드
    func uploadPost() {
        postObservable
            .map { currentUser, createdDate, festivalTitle, festivalId, title, detail, replyCount in
                return Post(id: UUID().uuidString, userId: currentUser?.id ?? "", nickname: currentUser?.nickname ?? "", profileImageURLString: currentUser?.profileImageURLString, createdDate: createdDate, festivalTitle: festivalTitle, festivalId: festivalId, title: title ?? "", detail: detail ?? "", replyCount: replyCount, reportCount: 0, reporterIds: [])
            }
            .take(1)
            .subscribe(onNext: {
                FirebaseFirestoreService.shared.setPostData(post: $0)
            })
            .disposed(by: disposeBag)
    }
    
    ///게시글 수정
    func editPost(postId: String) {
        postObservable
            .map { currentUser, createdDate, festivalTitle, festivalId, title, detail, _ in
                return Post(id: postId, userId: currentUser?.id ?? "", nickname: currentUser?.nickname ?? "", profileImageURLString: currentUser?.profileImageURLString, createdDate: createdDate, festivalTitle: festivalTitle, festivalId: festivalId, title: title ?? "", detail: detail ?? "", replyCount: 0, reportCount: 0, reporterIds: [])
            }
            .take(1)
            .subscribe(onNext: {
                FirebaseFirestoreService.shared.updatePostData(post: $0)
            })
            .disposed(by: disposeBag)
    }
    ///수정 중 일경우 게시글과 패치를 위한 게시글 Observable
    func postObservableForViewFetch(postId: String) -> Observable<Post> {
        FirebaseFirestoreService.shared.getSelectedPostData(postId: postId)
    }
}
