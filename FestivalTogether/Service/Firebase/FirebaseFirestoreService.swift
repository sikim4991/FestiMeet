//
//  FirebaseFirestoreService.swift
//  FestivalTogether
//
//  Created by SIKim on 10/9/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseMessaging

///Firebase - Firestore와 관련된 서비스
class FirebaseFirestoreService {
    static let shared = FirebaseFirestoreService()
    
    private let disposeBag = DisposeBag()
    var currentUserSubject = BehaviorSubject<User?>(value: nil)
    
    private let db = Firestore.firestore()
    private var lastPostQueryDocumentSnapshot: QueryDocumentSnapshot?
    private var lastSearchPostQueryDocumentSnapshot: QueryDocumentSnapshot?
    private var lastMyPostQueryDocumentSnapshot: QueryDocumentSnapshot?
    private var lastMyReplyQueryDocumentSnapshot: QueryDocumentSnapshot?
    private var lastMyReplyCommentQueryDocumentSnapshot: QueryDocumentSnapshot?
    
    private init() { }
    
    //MARK: User 관련 메소드
    ///Firestore에 User 데이터 저장
    func setUserData(nickname: String) async {
        if let auth = Auth.auth().currentUser {
            if await isCheckUserData() {
                do {
                    let tokenString = try await Messaging.messaging().token()
                    let user = User(id: auth.uid, nickname: nickname, profileImageURLString: nil, email: auth.email ?? "", notificationCheckedDate: Date(), reportCount: 0, reporterIds: [], notificationToken: tokenString)
                    try db.collection("User").document("\(auth.uid)").setData(from: user)
                } catch {
                    print("Error saving user data: \(error)")
                }
            }
        }
    }
    
    ///Firestore에서 User 데이터 가져옴
    func getUserData() -> Observable<User> {
        if (try? currentUserSubject.value()) != nil {
            return currentUserSubject.compactMap { $0 }
        } else {
            return Observable.create() { [weak self] emitter in
                guard let self else {
                    emitter.onError("Weak self is nil" as! Error)
                    return Disposables.create()
                }
                guard let userId = UserDefaults.standard.string(forKey: "UserID") else {
                    emitter.onError("UserDefaults is nil" as! Error)
                    return Disposables.create()
                }
                
                Task {
                    do {
                        var currentUser = try await self.db.collection("User").document(userId).getDocument(as: User.self)
                        let tokenString = try await Messaging.messaging().token()
                        
                        if currentUser.notificationToken != tokenString {
                            currentUser.notificationToken = tokenString
                            try await self.db.collection("User").document(userId).updateData(["notificationToken": tokenString])
                        }
                        emitter.onNext(currentUser)
                        emitter.onCompleted()
                    } catch {
                        print("Error: \(error)")
                        UserDefaults.standard.set(nil, forKey: "UserID")
                        emitter.onError(error)
                    }
                }
                
                return Disposables.create {
                    print("getUserData")
                }
            }
        }
    }
    
    ///Firestore의 User 데이터 삭제
    func removeUserData(completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        
        //nil일 경우 재인증이 필요하단 뜻이라서 false 반환
        guard let userId = user?.uid else {
            completion(false)
            return
        }
        
        db.collection("User").document(userId).collection("UserNotification").document().delete { [weak self] error in
            if let error = error {
                print("Error = \(error)")
                completion(false)
            } else {
                self?.db.collection("User").document(userId).delete { error in
                    if let error = error {
                        print("Error = \(error)")
                        completion(false)
                    } else {
                        user?.delete { error in
                            if let error = error {
                                print("Error = \(error)")
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }

    ///지금 로그인한 User의 데이터가 Firestore에 있는지 확인 (첫 로그인 판단)
    func isCheckUserData() async -> Bool {
        if let auth = Auth.auth().currentUser {
            do {
                let querySnapshot = try await db.collection("User").whereField("id", isEqualTo: auth.uid).getDocuments()
                if querySnapshot.documents.isEmpty {
                    return true
                } else {
                    return false
                }
            } catch {
                print("Error: \(error)")
                return false
            }
        }
        return false
    }
    
    ///Firestore에 User 필드의 nickname 업데이트
    func updateNickname(nickname: String) async {
        var currentUser = try? currentUserSubject.value()
        
        currentUser?.nickname = nickname
        
        do {
            try await db.collection("User").document(currentUser?.id ?? "").updateData(["nickname" : nickname])
            currentUserSubject.onNext(currentUser)
        } catch {
            print("Error: \(error)")
        }
    }
    
    ///닉네임 중복 확인
    func isCheckNickname(nickname: String) async -> Bool {
        do {
            let querySnapshot = try await db.collection("User").whereField("nickname", isEqualTo: nickname).getDocuments()
            if querySnapshot.documents.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            print("Error fetching documents: \(error)")
            return false
        }
    }
    
    ///Firestore에 User 필드 profileImageURLString 업데이트
    func updateProfileImageURLString(imageURLString: String) async {
        var currentUser = try? currentUserSubject.value()
        
        currentUser?.profileImageURLString = imageURLString
        
        do {
            try await db.collection("User").document(currentUser?.id ?? "").updateData(["profileImageURLString" : imageURLString])
            currentUserSubject.onNext(currentUser)
        } catch {
            print("Error: \(error)")
        }
    }
    
    ///Firestore에 User 필드 profileImageURLString 삭제
    func removeProfileImageURLString() {
        guard var currentUser = try? currentUserSubject.value() else { return }
        
        Task {
            await FirebaseStorageService.shared.removeImage(profileImageURLString: currentUser.profileImageURLString ?? "")
            currentUser.profileImageURLString = nil
            
            do {
                try await db.collection("User").document(currentUser.id).updateData(["profileImageURLString" : nil])
                currentUserSubject.onNext(currentUser)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    ///Firebase에 User필드 신고 받은 수와 신고자 저장 또는 업데이트
    func setUserReport(userId: String) -> Observable<Bool> {
        Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                do {
                    //만약 동시에 한 유저를 여러 명이 신고했을 경우, 카운트가 꼬이지 않기 위해 트랜잭션 이용 (읽기 후 쓰기 한번에 작업)
                    let _ = try await self.db.runTransaction { (transaction, errorPointer) -> Any? in
                        do {
                            let userDocument = try transaction.getDocument(self.db.collection("User").document(userId))
                            let user = try userDocument.data(as: User.self)
                            
                            if user.reporterIds.contains(try self.currentUserSubject.value()?.id ?? "") {
                                emitter.onNext(false)
                            } else {
                                if user.reportCount < 3 {
                                    transaction.updateData(["reportCount": user.reportCount + 1], forDocument: self.db.collection("User").document(userId))
                                    transaction.updateData(["reporterIds": FieldValue.arrayUnion([try self.currentUserSubject.value()?.id ?? ""])], forDocument: self.db.collection("User").document(userId))
                                }
                                emitter.onNext(true)
                            }
                            emitter.onCompleted()
                            return nil
                        } catch {
                            print("Error : \(error)")
                            emitter.onError(error)
                            return nil
                        }
                    }
                } catch {
                    print("Error : \(error)")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    ///해당 댓글과 관련있는 User 데이터 가져옴
    func getReplyUsers(replyId: String) -> Observable<[User]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            
            Task {
                do {
                    var tempUserIds: [String] = []
                    var tempUsers: [User] = []
                    
                    let replyUser = try await self.db.collection("Reply").document(replyId).getDocument(as: Reply.self)
                    tempUserIds.append(replyUser.userId)
                    
                    let queryDocumentSnapshot = try await self.db.collection("ReplyComment").whereField("replyId", isEqualTo: replyId).getDocuments()
                    
                    //댓글들의 User id 수집
                    queryDocumentSnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: ReplyComment.self)
                            if !tempUserIds.contains(data.userId) {
                                tempUserIds.append(data.userId)
                            }
                        } catch {
                            print("ReplyComment Data Convert Error")
                            emitter.onError(error)
                        }
                    }
                    
                    //사용자 id 제거
                    tempUserIds.removeAll(where: { UserDefaults.standard.string(forKey: "UserID") == $0 })
                    
                    //User 데이터 가져옴
                    for userId in tempUserIds {
                        do {
                            let userData = try await self.db.collection("User").document(userId).getDocument(as: User.self)
                            tempUsers.append(userData)
                        } catch {
                            print("User Data Convert Error")
                        }
                    }
                    
                    emitter.onNext(tempUsers)
                    emitter.onCompleted()
                } catch {
                    print("Send Reply Notification Error")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    ///해당 id의 User 닉네임, 프로필 사진 URL 가져옴
    func getOtherUserNicknameAndProfile(otherId: String) async -> (String, String?) {
        var resultData: (String, String?) = ("", nil)
        do {
            let data = try await db.collection("User").document(otherId).getDocument(as: User.self)
            resultData = (data.nickname, data.profileImageURLString)
        } catch {
            print("Error : \(error)")
        }
        
        return resultData
    }
    
    //MARK: UserNotification 관련 메소드
    ///Push Notification을 위한 Token을 가져옴
    func getUserNotificationToken(otherId: String) -> Observable<String> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            if otherId != UserDefaults.standard.string(forKey: "UserID") {
                Task {
                    do {
                        let otherUser = try await self.db.collection("User").document(otherId).getDocument(as: User.self)
                        emitter.onNext(otherUser.notificationToken)
                        emitter.onCompleted()
                    } catch {
                        print("Get User Token Function Error")
                        emitter.onError(error)
                    }
                }
            } else {
                emitter.onNext("")
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///게시판 새 알림을 확인했는지 확인
    func isCheckLastNotification() -> Observable<Bool> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            guard let currentUser = try? currentUserSubject.value() else { return Disposables.create() }
            
            Task {
                do {
                    let querySnapshot = try await self.db.collection("User").document(currentUser.id).collection("UserNotification").order(by: "receivedDate", descending: true).limit(to: 1).getDocuments()
                    
                    //새 알림에 대한 마지막 확인 날짜 비교
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: UserNotification.self)
                            data.receivedDate > currentUser.notificationCheckedDate ? emitter.onNext(true) : emitter.onNext(false)
                        } catch {
                            print("isCheckLastNotification Data Convert Error: \(error)")
                            emitter.onNext(false)
                            emitter.onError(error)
                        }
                    }
                } catch {
                    print("isCheckLastNotification error: \(error)")
                    emitter.onError(error)
                }
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///알림 확인 날짜 업데이트
    func updateNotificationCheckedDate() {
        do {
            guard var currentUser = try currentUserSubject.value() else { return }
            currentUser.notificationCheckedDate = Date()
            currentUserSubject.onNext(currentUser)
            db.collection("User").document(currentUser.id).updateData(["notificationCheckedDate": currentUser.notificationCheckedDate])
        } catch {
            print("updateupdateNotificationCheckedDate Error : \(error)")
        }
    }
    
    ///Firebase User컬렉션 하위에 UserNotification 컬렉션으로 Notification 데이터 저장
    func setNotificationData(postId: String?, userId: String, title: String, body: String) {
        do {
            let notificationData = UserNotification(title: title, body: body, receivedDate: Date(), postId: postId)
            try self.db.collection("User").document(userId).collection("UserNotification").document().setData(from: notificationData)
        } catch {
            print("setNotification Error : \(error)")
        }
    }
    
    ///UserNotification 데이터 가져옴
    func getNotificationData() -> Observable<[UserNotification]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            guard let currentUser = try? currentUserSubject.value() else { return Disposables.create() }
            var tempNotifications: [UserNotification] = []
            
            Task {
                do {
                    //확인안한 최신 알림 중 20개 제한
                    let querySnapshot = try await self.db.collection("User").document(currentUser.id).collection("UserNotification").order(by: "receivedDate", descending: true).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: UserNotification.self)
                            data.receivedDate > currentUser.notificationCheckedDate ? tempNotifications.append(data) : nil
                        } catch {
                            print("getNotification document Error : \(error)")
                            emitter.onError(error)
                        }
                    }
                    emitter.onNext(tempNotifications)
                    emitter.onCompleted()
                } catch {
                    print("getNotification querySnapshot Error : \(error)")
                    emitter.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    //MARK: Post 관련 메소드
    ///Firestore에 Post 데이터 저장
    func setPostData(post: Post) {
        do {
            try db.collection("Post").document("\(post.id)").setData(from: post)
        } catch {
            print("Error: \(error)")
        }
    }
    
    ///Post 데이터 일부 필드 업데이트 (게시글 수정)
    func updatePostData(post: Post) {
        db.collection("Post").document(post.id).updateData([
            "festivalTitle": post.festivalTitle,
            "festivalId": post.festivalId,
            "title": post.title,
            "detail": post.detail
        ])
    }
    
    ///'게시판'에서 Paging을 위한 최근 20개 Post 데이터만 가져옴 (첫 페이지)
    func getFirstPagePostData() -> Observable<[Post]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                var tempPost: [Post] = []
                
                do {
                    let querySnapshot = try await self.db.collection("Post").order(by: "createdDate", descending: true).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Post.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //다음 페이징을 위한 마지막 쿼리스냅샷 저장
                    self.lastPostQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///'게시판'에서 마지막 쿼리스냅샷 기준 다음 페이지 20개 데이터 가져옴
    func getPagePostData() -> Observable<[Post]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            guard let lastPostQueryDocumentSnapshot else { return Disposables.create() }
            Task {
                var tempPost: [Post] = []
                
                do {
                    let querySnapshot = try await self.db.collection("Post").order(by: "createdDate", descending: true).start(afterDocument: lastPostQueryDocumentSnapshot).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Post.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //다음 페이징을 위한 마지막 쿼리스냅샷 저장
                    self.lastPostQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///'게시판 검색'에서 Paging을 위한 최근 20개 Post 데이터만 가져옴 (첫 페이지)
    func getFirstPageSearchPostData(searchText: String) -> Observable<[Post]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                var tempPost: [Post] = []
                
                do {
                    let querySnapshot = try await self.db.collection("Post").order(by: "createdDate", descending: true).whereField("festivalTitle", isEqualTo: searchText).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Post.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //다음 페이징을 위한 마지막 쿼리스냅샷 저장
                    self.lastSearchPostQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///'게시판 검색'에서 마지막 쿼리스냅샷 기준 다음 페이지 20개 데이터 가져옴
    func getPageSearchPostData(searchText: String) -> Observable<[Post]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            guard let lastSearchPostQueryDocumentSnapshot else { return Disposables.create() }
            Task {
                var tempPost: [Post] = []
                
                do {
                    let querySnapshot = try await self.db.collection("Post").order(by: "createdDate", descending: true).whereField("festivalTitle", isEqualTo: searchText).start(afterDocument: lastSearchPostQueryDocumentSnapshot).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Post.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //다음 페이징을 위한 마지막 쿼리스냅샷 저장
                    self.lastSearchPostQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///'홈'에서 보여질 최근 3개의 Post 데이터 가져옴
    func getMainPostData() -> Observable<[Post]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                var tempPost: [Post] = []
                
                do {
                    let querySnapshot = try await self.db.collection("Post").order(by: "createdDate", descending: true).limit(to: 3).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Post.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///선택한 Post 데이터 가져옴
    func getSelectedPostData(postId: String) -> Observable<Post> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                do {
                    let data = try await self.db.collection("Post").document(postId).getDocument(as: Post.self)
                    emitter.onNext(data)
                    emitter.onCompleted()
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    ///'내가 쓴 글'에서 Paging을 위한 최근 20개 Post 데이터만 가져옴 (첫 페이지)
    func getFirstPageMyPostData() -> Observable<[Post]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                var tempPost: [Post] = []
                
                do {
                    guard let currentUser = try self.currentUserSubject.value() else { return }
                    let querySnapshot = try await self.db.collection("Post").whereField("userId", isEqualTo: currentUser.id).order(by: "createdDate", descending: true).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Post.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    self.lastMyPostQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///'내가 쓴 글'에서 마지막 쿼리스냅샷 기준 다음 페이지 20개 데이터 가져옴
    func getPageMyPostData() -> Observable<[Post]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            guard let lastMyPostQueryDocumentSnapshot else { return Disposables.create() }
            Task {
                var tempPost: [Post] = []
                
                do {
                    guard let currentUser = try self.currentUserSubject.value() else { return }
                    let querySnapshot = try await self.db.collection("Post").whereField("userId", isEqualTo: currentUser.id).order(by: "createdDate", descending: true).start(afterDocument: lastMyPostQueryDocumentSnapshot).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Post.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    self.lastMyPostQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///Firestore에 해당 Post 데이터 삭제
    func removePostData(postId: String) async {
            do {
                let replyQuerySnapshot = try await self.db.collection("Reply").whereField("postId", isEqualTo: postId).getDocuments()
                let replyCommentQuerySnapshot = try await self.db.collection("ReplyComment").whereField("postId", isEqualTo: postId).getDocuments()
                
                //해당 게시글의 대댓글 삭제
                replyCommentQuerySnapshot.documents.forEach { document in
                    Task {
                        do {
                            let data = try document.data(as: ReplyComment.self)
                            try await self.db.collection("ReplyComment").document(data.id).delete()
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
                
                //해당 게시글의 댓글 삭제
                replyQuerySnapshot.documents.forEach { document in
                    Task {
                        do {
                            let data = try document.data(as: Reply.self)
                            try await self.db.collection("Reply").document(data.id).delete()
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
                
                try await db.collection("Post").document(postId).delete()
            } catch {
                print("Error removing document: \(error)")
            }
    }
    
    //MARK: Reply 관련 메소드
    //Firestore에 Reply 데이터 저장
    func setReplyData(reply: Reply) {
        Task {
            do {
                try db.collection("Reply").document(reply.id).setData(from: reply)
                
                //여러 사람이 동시에 댓글을 썼을 경우를 위해 Post의 replyCount증가를 트랜잭션으로 구현
                let _ = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                    do {
                        let document = try transaction.getDocument(self.db.collection("Post").document(reply.postId))
                        guard let oldReplyCount = document.data()?["replyCount"] as? Int else {
                            let error = NSError(
                                domain: "AppErrorDomain",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(document)"
                                ]
                            )
                            errorPointer?.pointee = error
                            return nil
                        }
                        
                        transaction.updateData(["replyCount": oldReplyCount + 1], forDocument: self.db.collection("Post").document(reply.postId))
                        return nil
                    } catch {
                        print("Error: \(error)")
                        return nil
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    //Firestore에 Reply 데이터 삭제
    func removeReplyData(reply: Reply) async {
        var replyCount = 1
        
        do {
            let replyCommentQuerySnapshot = try await self.db.collection("ReplyComment").whereField("replyId", isEqualTo: reply.id).getDocuments()
            
            //해당댓글의 대댓글 데이터 삭제
            replyCommentQuerySnapshot.documents.forEach { document in
                Task {
                    do {
                        let data = try document.data(as: ReplyComment.self)
                        try await self.db.collection("ReplyComment").document(data.id).delete()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            
            try await db.collection("Reply").document(reply.id).delete()
            replyCount += replyCommentQuerySnapshot.count
            
            //동시 발생을 대비한 트랜잭션 구현
            let _ = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                do {
                    let document = try transaction.getDocument(self.db.collection("Post").document(reply.postId))
                    guard let oldReplyCount = document.data()?["replyCount"] as? Int else {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(document)"
                            ]
                        )
                        errorPointer?.pointee = error
                        return nil
                    }
                    
                    transaction.updateData(["replyCount": oldReplyCount - replyCount], forDocument: self.db.collection("Post").document(reply.postId))
                    return nil
                } catch {
                    print("Error: \(error)")
                    return nil
                }
            }
        } catch {
            print("Error removing document: \(error)")
        }
    }
    
    ///Reply 데이터를 가져옴
    func getReplyData(postId: String) -> Observable<[Reply]> {
        var data: [Reply] = []
        
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                do {
                    let querySnapshot = try await self.db.collection("Reply").whereField("postId", isEqualTo: postId).order(by: "createdDate", descending: false).getDocuments()
                    querySnapshot.documents.forEach { document in
                        if document.exists {
                            do {
                                data.append(try document.data(as: Reply.self))
                            } catch {
                                print("Error: \(error)")
                                emitter.onError(error)
                            }
                        }
                    }
                    emitter.onNext(data)
                    emitter.onCompleted()
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    ///'내가 쓴 댓글' 에서 첫 페이지 데이터 가져옴 (최근 20개)
    func getFirstPageMyReplyData() -> Observable<[Reply]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                var tempPost: [Reply] = []
                
                do {
                    guard let currentUser = try self.currentUserSubject.value() else { return }
                    let querySnapshot = try await self.db.collection("Reply").whereField("userId", isEqualTo: currentUser.id).order(by: "createdDate", descending: true).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Reply.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //마지막 쿼리스냅샷 저장
                    self.lastMyReplyQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///'내가 쓴 댓글' 마지막 쿼리스냅샷 기준 다음 페이지 데이터 가져옴
    func getPageMyReplyData() -> Observable<[Reply]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            guard let lastMyReplyQueryDocumentSnapshot else { return Disposables.create() }
            Task {
                var tempPost: [Reply] = []
                
                do {
                    guard let currentUser = try self.currentUserSubject.value() else { return }
                    let querySnapshot = try await self.db.collection("Reply").whereField("userId", isEqualTo: currentUser.id).order(by: "createdDate", descending: true).start(afterDocument: lastMyReplyQueryDocumentSnapshot).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: Reply.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //마지막 쿼리스냅샷 저장
                    self.lastMyReplyQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    //MARK: ReplyComment 관련 메소드
    ///Firestore에 ReplyComment 데이터 저장
    func setReplyCommentData(replyComment: ReplyComment) {
        Task {
            do {
                try db.collection("ReplyComment").document(replyComment.id).setData(from: replyComment)
                
                //게시글 replyCount를 트랜잭션으로 구현
                let _ = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                    do {
                        let document = try transaction.getDocument(self.db.collection("Post").document(replyComment.postId))
                        guard let oldReplyCount = document.data()?["replyCount"] as? Int else {
                            let error = NSError(
                                domain: "AppErrorDomain",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(document)"
                                ]
                            )
                            errorPointer?.pointee = error
                            return nil
                        }
                        
                        transaction.updateData(["replyCount": oldReplyCount + 1], forDocument: self.db.collection("Post").document(replyComment.postId))
                        return nil
                    } catch {
                        print("Error: \(error)")
                        return nil
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    ///Firestroe에 ReplyComment 데이터 삭제
    func removeReplyCommentData(replyComment: ReplyComment) {
        Task {
            do {
                try await db.collection("ReplyComment").document(replyComment.id).delete()
                
                //replyCount 감소를 트랜잭션으로 구현
                let _ = try await db.runTransaction { (transaction, errorPointer) -> Any? in
                    do {
                        let document = try transaction.getDocument(self.db.collection("Post").document(replyComment.postId))
                        guard let oldReplyCount = document.data()?["replyCount"] as? Int else {
                            let error = NSError(
                                domain: "AppErrorDomain",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(document)"
                                ]
                            )
                            errorPointer?.pointee = error
                            return nil
                        }
                        
                        transaction.updateData(["replyCount": oldReplyCount - 1], forDocument: self.db.collection("Post").document(replyComment.postId))
                        return nil
                    } catch {
                        print("Error: \(error)")
                        return nil
                    }
                }
            } catch {
                print("Error removing document: \(error)")
            }
        }
    }
    
    ///ReplyComment 데이터 가져옴
    func getReplyCommentData(postId: String) -> Observable<[ReplyComment]> {
        var data: [ReplyComment] = []
        
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                do {
                    let querySnapshot = try await self.db.collection("ReplyComment").whereField("postId", isEqualTo: postId).order(by: "createdDate", descending: false).getDocuments()
                    querySnapshot.documents.forEach { document in
                        if document.exists {
                            do {
                                data.append(try document.data(as: ReplyComment.self))
                            } catch {
                                print("Error: \(error)")
                                emitter.onError(error)
                            }
                        }
                    }
                    emitter.onNext(data)
                    emitter.onCompleted()
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    ///'내가 쓴 댓글'에서 첫 페이지를 위한 ReplyComment 데이터 가져옴
    func getFirstPageMyReplyCommentData() -> Observable<[ReplyComment]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                var tempPost: [ReplyComment] = []
                
                do {
                    guard let currentUser = try self.currentUserSubject.value() else { return }
                    let querySnapshot = try await self.db.collection("ReplyComment").whereField("userId", isEqualTo: currentUser.id).order(by: "createdDate", descending: true).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: ReplyComment.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //마지막 쿼리스냅샷 저장
                    self.lastMyReplyCommentQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///'내가 쓴 댓글'에서 마지막 쿼리스냅샨 기준 다음 페이지를 위한 ReplyComment 데이터 가져옴
    func getPageMyReplyCommentData() -> Observable<[ReplyComment]> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            guard let lastMyReplyCommentQueryDocumentSnapshot else { return Disposables.create() }
            Task {
                var tempPost: [ReplyComment] = []
                
                do {
                    guard let currentUser = try self.currentUserSubject.value() else { return }
                    let querySnapshot = try await self.db.collection("ReplyComment").whereField("userId", isEqualTo: currentUser.id).order(by: "createdDate", descending: true).start(afterDocument: lastMyReplyCommentQueryDocumentSnapshot).limit(to: 20).getDocuments()
                    
                    querySnapshot.documents.forEach { document in
                        do {
                            let data = try document.data(as: ReplyComment.self)
                            tempPost.append(data)
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                        }
                    }
                    //마지막 쿼리스냅샷 저장
                    self.lastMyReplyCommentQueryDocumentSnapshot = querySnapshot.documents.last
                } catch {
                    print("Error: \(error)")
                    emitter.onError(error)
                }
                emitter.onNext(tempPost)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    //MARK: 게시판 Report 관련 메소드
    ///게시글 신고 카운트 업데이트
    func updatePostReport(postId: String) -> Observable<Bool> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                do {
                    //트랜잭션 구현
                    let _ = try await self.db.runTransaction { (transaction, errorPointer) -> Any? in
                        do {
                            let postDocument = try transaction.getDocument(self.db.collection("Post").document(postId))
                            let post = try postDocument.data(as: Post.self)
                            let userDocument = try transaction.getDocument(self.db.collection("User").document(post.userId))
                            let user = try userDocument.data(as: User.self)
                            
                            //한 사람이 여러번 신고 방지
                            if post.reporterIds.contains(try self.currentUserSubject.value()?.id ?? "") {
                                emitter.onNext(false)
                            } else {
                                //신고 누적 5개 이상 달성 시 글 삭제 및 사용자 신고 카운트 누적
                                if post.reportCount < 5 {
                                    transaction.updateData(["reportCount": post.reportCount + 1], forDocument: self.db.collection("Post").document(postId))
                                    transaction.updateData(["reporterIds": FieldValue.arrayUnion([try self.currentUserSubject.value()?.id ?? ""])], forDocument: self.db.collection("Post").document(postId))
                                }
                                
                                if post.reportCount + 1 >= 5 {
                                    transaction.updateData(["reportCount": user.reportCount + 1], forDocument: self.db.collection("User").document(post.userId))
                                    self.db.collection("Post").document(postId).delete() { _ in
                                        FirebaseCloudMessagingService.shared.sendPushNotificationAboutReport(otherId: user.id, title: "게시글 삭제 안내", body: "신고 누적으로 인해 게시글이 삭제되었습니다.")
                                    }
                                }
                                emitter.onNext(true)
                            }
                            emitter.onCompleted()
                            return nil
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                            return nil
                        }
                    }
                } catch {
                    print("Error removing document: \(error)")
                    emitter.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    ///댓글 신고 카운트 업데이트
    func updateReplyReport(replyId: String) -> Observable<Bool> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                do {
                    //트랜잭션 구현
                    let _ = try await self.db.runTransaction { (transaction, errorPointer) -> Any? in
                        do {
                            let replyDocument = try transaction.getDocument(self.db.collection("Reply").document(replyId))
                            let reply = try replyDocument.data(as: Reply.self)
                            let userDocument = try transaction.getDocument(self.db.collection("User").document(reply.userId))
                            let user = try userDocument.data(as: User.self)
                            
                            //한 사람이 여러번 신고 방지
                            if reply.reporterIds.contains(try self.currentUserSubject.value()?.id ?? "") {
                                emitter.onNext(false)
                            } else {
                                //신고 누적 5개 이상 달성 시 댓글 삭제 및 사용자 신고 카운트 누적
                                if reply.reportCount < 5 {
                                    transaction.updateData(["reportCount": reply.reportCount + 1], forDocument: self.db.collection("Reply").document(replyId))
                                    transaction.updateData(["reporterIds": FieldValue.arrayUnion([try self.currentUserSubject.value()?.id ?? ""])], forDocument: self.db.collection("Reply").document(replyId))
                                }
                                
                                if reply.reportCount + 1 >= 5 {
                                    transaction.updateData(["reportCount": user.reportCount + 1], forDocument: self.db.collection("User").document(reply.userId))
                                    self.db.collection("Reply").document(replyId).delete() { _ in
                                        FirebaseCloudMessagingService.shared.sendPushNotificationAboutReport(otherId: user.id, title: "댓글 삭제 안내", body: "신고 누적으로 인해 댓글이 삭제되었습니다.")
                                    }
                                }
                                emitter.onNext(true)
                            }
                            emitter.onCompleted()
                            return nil
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                            return nil
                        }
                    }
                } catch {
                    print("Error removing document: \(error)")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    ///대댓글 신고 카운트 업데이트
    func updateReplyCommentReport(replyCommentId: String) -> Observable<Bool> {
        return Observable.create() { [weak self] emitter in
            guard let self else { return Disposables.create() }
            Task {
                do {
                    //트랜잭션 구현
                    let _ = try await self.db.runTransaction { (transaction, errorPointer) -> Any? in
                        do {
                            let replyCommentDocument = try transaction.getDocument(self.db.collection("ReplyComment").document(replyCommentId))
                            let replyComment = try replyCommentDocument.data(as: ReplyComment.self)
                            let userDocument = try transaction.getDocument(self.db.collection("User").document(replyComment.userId))
                            let user = try userDocument.data(as: User.self)
                            
                            //한 사람이 여러번 신고 방지
                            if replyComment.reporterIds.contains(try self.currentUserSubject.value()?.id ?? "") {
                                emitter.onNext(false)
                            } else {
                                //신고 누적 5개 이상 달성 시 댓글 삭제 및 사용자 신고 카운트 누적
                                if replyComment.reportCount < 5 {
                                    transaction.updateData(["reportCount": replyComment.reportCount + 1], forDocument: self.db.collection("ReplyComment").document(replyCommentId))
                                    transaction.updateData(["reporterIds": FieldValue.arrayUnion([try self.currentUserSubject.value()?.id ?? ""])], forDocument: self.db.collection("ReplyComment").document(replyCommentId))
                                }
                                
                                if replyComment.reportCount + 1 >= 5 {
                                    transaction.updateData(["reportCount": user.reportCount + 1], forDocument: self.db.collection("User").document(replyComment.userId))
                                    self.db.collection("ReplyComment").document(replyCommentId).delete() { _ in
                                        FirebaseCloudMessagingService.shared.sendPushNotificationAboutReport(otherId: user.id, title: "대댓글 삭제 안내", body: "신고 누적으로 인해 대댓글이 삭제되었습니다.")
                                    }
                                }
                                emitter.onNext(true)
                            }
                            emitter.onCompleted()
                            return nil
                        } catch {
                            print("Error: \(error)")
                            emitter.onError(error)
                            return nil
                        }
                    }
                } catch {
                    print("Error removing document: \(error)")
                    emitter.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    //MARK: Chatting, Message 관련 메소드
    ///Firestore에서 사용자가 참여중인 Chatting 데이터들을 실시간으로 가져옴 (채팅리스트)
    func getChattingInfoData() -> Observable<[Chatting]> {
        return Observable.create { [weak self] emitter in
            //리스너를 통해 실시간으로 해당하는 데이터 변경, 생성 감지
            let listener = self?.db.collection("Chatting").whereField("memberIds", arrayContains: UserDefaults.standard.string(forKey: "UserID")).addSnapshotListener { querySnapshot, error in
                guard let querySnapshot else { return }
                var chattingList: [Chatting] = []
                
                querySnapshot.documents.forEach { document in
                    do {
                        chattingList.append(try document.data(as: Chatting.self))
                    } catch {
                        print("Error: \(error)")
                        emitter.onError(error)
                    }
                }
                emitter.onNext(chattingList)
            }
            
            return Disposables.create {
                listener?.remove()
            }
        }
    }
    
    ///Firestore에 Chatting 및 Message 데이터 저장 (첫 메시지 시 생성)
    func setChattingMessageData(chatting: Chatting, message: Message) async {
        var tempChatting = chatting
        var nickAndProfile: (String, String?) = ("", nil)
        
        //채팅 멤버들의 닉네임, 프로필을 반영
        for (index, userId) in chatting.memberIds.enumerated() {
            if index > 0 {
                nickAndProfile = await getOtherUserNicknameAndProfile(otherId: userId)
                tempChatting.chattingName = tempChatting.chattingName + ", \(nickAndProfile.0)"
                tempChatting.members.append(Member(userId: userId, nickname: nickAndProfile.0, profileImageURLString: nickAndProfile.1, startDate: Date() - 10, lastReadDate: Date() - 10))
            }
        }
        
        do {
            try db.collection("Chatting").document(tempChatting.id).setData(from: tempChatting) { [weak self] _ in
                do {
                    try self?.db.collection("Chatting").document(tempChatting.id).collection("Messages").document().setData(from: message)
                } catch {
                    print("Error : \(error)")
                }
            }
        } catch {
            print("Error : \(error)")
        }
    }
    
    ///Firestore에서 Chatting 데이터 가져옴
    func getChattingData(chattingId: String) -> Observable<Chatting> {
        return Observable.create { [weak self] emitter in
            Task {
                let chattingData = await self?.updateChattingData(chattingId: chattingId)
                guard let chattingData else { return }
                
                emitter.onNext(chattingData)
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///Firestore에서 해당 Chatting의 Message 데이터들을 가져옴
    func getMessageData(chattingId: String) -> Observable<[Message]> {
        return Observable.create { [weak self] emitter in
            guard let self else { return Disposables.create() }
            var listener: (any ListenerRegistration)?
            
            Task {
                let chattingData = await self.updateChattingData(chattingId: chattingId)
                var lastReadDate = Date()
                
                chattingData.members.forEach({ member in
                    if member.userId == UserDefaults.standard.string(forKey: "UserID") {
                        lastReadDate = member.lastReadDate
                    }
                })
                
                //리스너를 활용해 마지막 읽은 날짜 이후의 메시지들을 실시간으로 가져옴
                listener = self.db.collection("Chatting").document(chattingId).collection("Messages").whereField("senderDate", isGreaterThan: lastReadDate).addSnapshotListener { documentSnapshot, error in
                    var messagesData: [Message] = []
                    guard let documentSnapshot else { return }
                    
                    documentSnapshot.documentChanges.forEach { documentChange in
                        if documentChange.type == .added {
                            messagesData.append(try! documentChange.document.data(as: Message.self))
                        }
                    }
                    emitter.onNext(messagesData)
                }
            }
            
            return Disposables.create { [weak self] in
                self?.updateLastReadDate(chattingId: chattingId)
                listener?.remove()
            }
        }
    }
    
    ///Chatting 데이터 내에 닉네임 변경, 프로필 이미지 변경 등을 반영
    func updateChattingData(chattingId: String) async -> Chatting {
        do {
            var chattingData = try await db.collection("Chatting").document(chattingId).getDocument(as: Chatting.self)
            var chattingName = ""
            var nickAndProfile: (String, String?) = ("", nil)
            
            //채팅 멤버들 닉네임, 프로필 사진 가져옴
            for (index, member) in chattingData.members.enumerated() {
                if member.userId != UserDefaults.standard.string(forKey: "UserID") {
                    nickAndProfile = await getOtherUserNicknameAndProfile(otherId: member.userId)
                    chattingData.members[index].nickname = nickAndProfile.0
                    chattingData.members[index].profileImageURLString = nickAndProfile.1
                }
                chattingName += chattingName == "" ? member.nickname : ", \(member.nickname)"
            }
            chattingData.chattingName = chattingName
            
            try db.collection("Chatting").document(chattingId).setData(from: chattingData, merge: true)
            return chattingData
        } catch {
            print("Error : \(error)")
            return Chatting(id: "", chattingName: "Error", memberIds: [], members: [])
        }
    }
    
    ///해당 Chatting의 메시지 업데이트
    func updateChattingMessageData(chattingId: String, message: Message) {
        let messageData: [String: Any] = [
                "senderId": message.senderId,
                "senderDate": message.senderDate,
                "senderMessage": message.senderMessage
            ]
        
        db.collection("Chatting").document(chattingId).updateData([
            "lastMessage" : message.senderMessage,
            "lastMessageDate" : message.senderDate,
        ])
        
        db.collection("Chatting").document(chattingId).collection("Messages").document().setData(messageData)
    }
    
    ///채팅방에 사용자가 마지막으로 읽은 날짜 업데이트
    func updateLastReadDate(chattingId: String) {
        Task {
            do {
                var chattingData = try await db.collection("Chatting").document(chattingId).getDocument(as: Chatting.self)
                
                for (index, member) in chattingData.members.enumerated() {
                    if member.userId == UserDefaults.standard.string(forKey: "UserID") {
                        chattingData.members[index].lastReadDate = Date()
                    }
                }
                
                try db.collection("Chatting").document(chattingId).setData(from: chattingData, merge: true)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    ///1:1 채팅방이 이미 있는지 확인
    func checkChattingData(userId: String, otherId: String) async -> String? {
        var chattingId: String?
        
        do {
            let querySnapshot = try await db.collection("Chatting").whereField("memberIds", arrayContains: userId).getDocuments()

            for document in querySnapshot.documents {
                if document.exists {
                    let data = try document.data(as: Chatting.self)
                    
                    if data.memberIds.count == 2 && data.memberIds.contains(otherId) {
                        chattingId = data.id
                    }
                }
            }
        } catch {
            print("Error : \(error)")
        }
        
        return chattingId
    }
    
    ///기존에 있는 채팅방에 멤버 추가 (최대 6명)
    func addChattingMember(chattingId: String, member: Member) {
        let memberData: [String: Any] = [
            "userId": member.userId,
            "nickname": member.nickname,
            "profileImageURLString": member.profileImageURLString,
            "startDate": member.startDate,
            "lastReadDate": member.lastReadDate
        ]
        
        db.collection("Chatting").document(chattingId).getDocument(as: Chatting.self) { [weak self] result in
            do {
                let chatting = try result.get()
                
                guard chatting.memberIds.contains(member.userId) || chatting.members.count >= 6 else {
                    self?.db.collection("Chatting").document(chattingId).updateData(["memberIds": FieldValue.arrayUnion([member.userId])])
                    self?.db.collection("Chatting").document(chattingId).updateData(["members": FieldValue.arrayUnion([memberData])])
                    
                    return
                }
            } catch {
                print("Error : \(error)")
            }
        }
    }
    
    //채팅방 멤버에서 사용자 삭제
    func removeChattingMember(chattingId: String, memberId: String) async {
        do {
            var data = try await db.collection("Chatting").document(chattingId).getDocument(as: Chatting.self)
            
            for (index, userId) in data.memberIds.enumerated() {
                if userId == memberId {
                    data.memberIds.remove(at: index)
                }
            }
            
            for (index, member) in data.members.enumerated() {
                if member.userId == memberId {
                    data.members.remove(at: index)
                }
            }
            
            try db.collection("Chatting").document(chattingId).setData(from: data, merge: true)
        } catch {
            print("Error : \(error)")
        }
    }
}
