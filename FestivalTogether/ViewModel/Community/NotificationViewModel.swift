//
//  NotificationViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 1/9/25.
//

import Foundation
import RxSwift
import RxCocoa

class NotificationViewModel {
    private let disposeBag = DisposeBag()
    ///알림 Array Observable
    lazy var notificationsObservable = FirebaseFirestoreService.shared.getNotificationData()
    
    ///마지막 알림 확인 날짜 업데이트
    func updateNotificationCheckedDate() {
        FirebaseFirestoreService.shared.updateNotificationCheckedDate()
    }
    
    ///선택한 알림의 게시글 Observable
    func loadSelectedPost(postId: String) -> Observable<Post> {
        FirebaseFirestoreService.shared.getSelectedPostData(postId: postId)
    }
    
    ///날짜 변환 String
    func convertDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dateFormatter.string(from: date)
    }
}
