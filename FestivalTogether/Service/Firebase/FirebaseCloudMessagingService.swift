//
//  FirebaseCloudMessagingService.swift
//  FestivalTogether
//
//  Created by SIKim on 12/21/24.
//

import Foundation
import Alamofire
import SwiftJWT
import OAuth2
import RxSwift
import FirebaseMessaging

struct MyClaims: Claims {
    var iss: String
    var scope: String
    var aud: String
    var exp: Int
    var iat: Int
}

///Firebase - Cloud Messaging과 관련된 서비스
class FirebaseCloudMessagingService {
    static let shared = FirebaseCloudMessagingService()
    
    private init() { }
    
    private let disposeBag = DisposeBag()
    private let scope = "https://www.googleapis.com/auth/firebase.messaging"
    private let tokenURL = "https://oauth2.googleapis.com/token"
    private let fcmURL = "https://fcm.googleapis.com/v1/projects/festivaltogether-7cf66/messages:send"
    
    ///서비스 계정 파일에서 인증 정보 추출
    private func getServiceAccountConfig() -> [String: String]? {
        guard let filePath = Bundle.main.path(forResource: "ServiceAccount", ofType: "json") else {
            print("service_account.json 파일을 찾을 수 없습니다.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let clientEmail = json["client_email"] as? String,
                  let privateKey = json["private_key"] as? String else {
                print("service_account.json에서 client_email 또는 private_key을 찾을 수 없습니다.")
                return nil
            }
            
            return ["client_email": clientEmail, "private_key": privateKey]
        } catch {
            print("service_account.json 파일 파싱 중 오류 발생: \(error.localizedDescription)")
            return nil
        }
    }
    
    ///JWT 생성 함수
    private func createJWT(clientEmail: String, privateKey: String) -> String? {
        let now = Int(Date().timeIntervalSince1970)
        let expiration = now + 3600 //1시간 후 만료
        
        //Claims 정의
        let claims = MyClaims(
            iss: clientEmail,
            scope: scope,
            aud: "https://oauth2.googleapis.com/token",
            exp: expiration,
            iat: now
        )
        
        do {
            //개인 키를 Data로 변환
            guard let privateKeyData = privateKey.data(using: .utf8) else {
                print("Private key를 데이터로 변환할 수 없습니다.")
                return nil
            }
            
            //JWT 서명 (RS256 알고리즘 사용)
            var jwt = JWT(claims: claims)
            let signedJWT = try jwt.sign(using: .rs256(privateKey: privateKeyData))
            
            
            return signedJWT
        } catch {
            print("JWT 생성 중 오류 발생: \(error.localizedDescription)")
            return nil
        }
    }
    
    ///OAuth2 인증 토큰을 얻는 함수
    func getOAuth2Token() -> Observable<String> {
        return Observable.create() { [weak self] emitter in
            //토큰 유효 시간 만료 기준
            guard UserDefaults.standard.double(forKey: "ExpToken") < Date().timeIntervalSince1970 else {
                guard let accessToken = UserDefaults.standard.string(forKey: "OAuth2Token") else { return Disposables.create() }
                emitter.onNext(accessToken)
                emitter.onCompleted()
                return Disposables.create()
            }
            guard let self else { return Disposables.create() }
            guard let config = self.getServiceAccountConfig(),
                  let clientEmail = config["client_email"],
                  let privateKey = config["private_key"] else { return Disposables.create() }
            
            //JWT 생성
            guard let jwt = self.createJWT(clientEmail: clientEmail, privateKey: privateKey) else { return Disposables.create() }
            
            let url = URL(string: self.tokenURL)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            //OAuth2 토큰 요청 파라미터
            let body: [String: String] = [
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": jwt // JWT를 assertion으로 전달
            ]
            
            request.httpBody = body.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
            
            //인증 토큰 획득
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        guard let data else { return }
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let accessToken = jsonResponse["access_token"] as? String,
                           let expToken = jsonResponse["expires_in"] as? Double{
                            UserDefaults.standard.set(accessToken, forKey: "OAuth2Token")
                            UserDefaults.standard.set(Date().timeIntervalSince1970 + expToken, forKey: "ExpToken")
                            emitter.onNext(accessToken)
                            emitter.onCompleted()
                        } else {
                            print("Error parsing token response: No access token found")
                        }
                    case .failure(let error):
                        emitter.onError(error)
                        break
                    }
                    
                }
            
            return Disposables.create()
        }
    }
    
    ///채팅 생성 후의 Push Notification 전송
    func sendPushNotificationAboutAfterChatting(topic: String, title: String, body: String) {
        getOAuth2Token().subscribe(onNext: { [weak self] in
            guard let self else { return }
            guard let url = URL(string: fcmURL) else {
                print("Invalid FCM URL")
                return
            }
            
            let message: [String: Any] = [
                "message": [
                    "topic": topic,
                    "notification": [
                        "title": title,
                        "body": body
                    ],
                    "apns": [
                        "payload": [
                            "aps": [
                                "sound": "default"
                            ]
                        ]
                    ]
                ]
            ]
            
            //요청 설정
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \($0)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
                request.httpBody = jsonData
            } catch {
                print("Failed to serialize JSON: \(error.localizedDescription)")
                return
            }
            
            //API 호출
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        guard let data else { return }
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if jsonResponse["name"] as? String != nil {
                                print("Success Send Notification")
                            } else {
                                print("Send Notification Error")
                            }
                        }
                    case .failure(let error):
                        print("FCM Topic Send Error : \(error)")
                        break
                    }
                }
        })
        .disposed(by: disposeBag)
    }
    
    ///채팅 생성 시 Push Notification 전송
    func sendPushNotificationAboutStartChatting(otherId: String, title: String, body: String) {
        Observable
            .combineLatest(getOAuth2Token(), FirebaseFirestoreService.shared.getUserNotificationToken(otherId: otherId))
            .subscribe(onNext: { [weak self] oAuth2Token, notificationToken in
                guard let self else { return }
                guard notificationToken != "" else { return }
                guard let url = URL(string: fcmURL) else {
                    print("Invalid FCM URL")
                    return
                }
                
                let message: [String: Any] = [
                    "message": [
                        "token": notificationToken,
                        "notification": [
                            "title": title,
                            "body": body
                        ],
                        "apns": [
                            "payload": [
                                "aps": [
                                    "sound": "default"
                                ]
                            ]
                        ]
                    ]
                ]
                
                //요청 설정
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(oAuth2Token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
                    request.httpBody = jsonData
                } catch {
                    print("Failed to serialize JSON: \(error.localizedDescription)")
                    return
                }
                
                //API 호출
                AF.request(request)
                    .response { response in
                        switch response.result {
                        case .success(let data):
                            guard let data else { return }
                            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if jsonResponse["name"] as? String != nil {
                                    print("Success Send Notification")
                                } else {
                                    print("Send Notification Error")
                                }
                            }
                        case .failure(let error):
                            print("FCM Topic Send Error : \(error)")
                            break
                        }
                    }
            })
            .disposed(by: disposeBag)
    }
    
    ///신고 관련 Push Notification 전송
    func sendPushNotificationAboutReport(otherId: String, title: String, body: String) {
        Observable
            .combineLatest(getOAuth2Token(), FirebaseFirestoreService.shared.getUserNotificationToken(otherId: otherId))
            .subscribe(onNext: { [weak self] oAuth2Token, notificationToken in
                guard let self else { return }
                guard notificationToken != "" else { return }
                guard let url = URL(string: fcmURL) else {
                    print("Invalid FCM URL")
                    return
                }
                
                let message: [String: Any] = [
                    "message": [
                        "token": notificationToken,
                        "notification": [
                            "title": title,
                            "body": body
                        ],
                        "apns": [
                            "payload": [
                                "aps": [
                                    "sound": "default"
                                ]
                            ]
                        ]
                    ]
                ]
                
                //요청 설정
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(oAuth2Token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
                    request.httpBody = jsonData
                } catch {
                    print("Failed to serialize JSON: \(error.localizedDescription)")
                    return
                }
                
                //API 호출
                AF.request(request)
                    .response { response in
                        switch response.result {
                        case .success(let data):
                            guard let data else { return }
                            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                FirebaseFirestoreService.shared.setNotificationData(postId: nil, userId: otherId, title: title, body: body)
                                if jsonResponse["name"] as? String != nil {
                                    print("Success Send Notification")
                                } else {
                                    print("Send Notification Error")
                                }
                            }
                        case .failure(let error):
                            print("FCM Topic Send Error : \(error)")
                            break
                        }
                    }
            })
            .disposed(by: disposeBag)
    }
    
    ///게시글 관련 Push Notification 전송
    func sendPushNotificationAboutPost(post: Post, body: String) {
        Observable
            .combineLatest(getOAuth2Token(), FirebaseFirestoreService.shared.getUserNotificationToken(otherId: post.userId))
            .subscribe(onNext: { [weak self] oAuth2Token, notificationToken in
                guard let self else { return }
                guard notificationToken != "" else { return }
                guard let url = URL(string: fcmURL) else {
                    print("Invalid FCM URL")
                    return
                }
                
                let message: [String: Any] = [
                    "message": [
                        "token": notificationToken,
                        "notification": [
                            "title": "'\(post.title)'",
                            "body": "나의 글에 댓글이 달렸어요: '\(body)'"
                        ],
                        "apns": [
                            "payload": [
                                "aps": [
                                    "sound": "default"
                                ]
                            ]
                        ]
                    ]
                ]
                
                //요청 설정
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(oAuth2Token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
                    request.httpBody = jsonData
                } catch {
                    print("Failed to serialize JSON: \(error.localizedDescription)")
                    return
                }
                
                //API 호출
                AF.request(request)
                    .response { response in
                        switch response.result {
                        case .success(let data):
                            guard let data else { return }
                            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                FirebaseFirestoreService.shared.setNotificationData(postId: post.id, userId: post.userId, title: "'\(post.title)'", body: "나의 글에 댓글이 달렸어요: '\(body)'")
                                if jsonResponse["name"] as? String != nil {
                                    print("Success Send Notification")
                                } else {
                                    print("Send Notification Error")
                                }
                            }
                        case .failure(let error):
                            print("FCM Topic Send Error : \(error)")
                            break
                        }
                    }
            })
            .disposed(by: disposeBag)
    }
    
    ///댓글 관련 Push Notification 전송
    func sendPushNotificationAboutReply(replyId: String, post: Post, body: String) {
        Observable
            .combineLatest(getOAuth2Token(), FirebaseFirestoreService.shared.getReplyUsers(replyId: replyId), FirebaseFirestoreService.shared.getUserNotificationToken(otherId: post.userId))
            .subscribe(onNext: { [weak self] oAuth2Token, replyUsers, postUserNotificationToken in
                guard let self else { return }
                guard let url = URL(string: fcmURL) else {
                    print("Invalid FCM URL")
                    return
                }
                
                if !replyUsers.map({ $0.notificationToken }).contains(postUserNotificationToken) && postUserNotificationToken != "" {
                    sendPushNotificationAboutPost(post: post, body: body)
                }
                
                replyUsers.forEach { replyUser in
                    let message: [String: Any] = [
                        "message": [
                            "token": replyUser.notificationToken,
                            "notification": [
                                "title": "'\(post.title)'",
                                "body": "나의 댓글에 대댓글이 달렸어요: '\(body)'"
                            ],
                            "apns": [
                                "payload": [
                                    "aps": [
                                        "sound": "default"
                                    ]
                                ]
                            ]
                        ]
                    ]
                    
                    //요청 설정
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(oAuth2Token)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
                        request.httpBody = jsonData
                    } catch {
                        print("Failed to serialize JSON: \(error.localizedDescription)")
                        return
                    }
                    
                    //API 호출
                    AF.request(request)
                        .response { response in
                            switch response.result {
                            case .success(let data):
                                guard let data else { return }
                                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    FirebaseFirestoreService.shared.setNotificationData(postId: post.id, userId: replyUser.id, title: "'\(post.title)'", body: "나의 댓글에 대댓글이 달렸어요: '\(body)'")
                                    if jsonResponse["name"] as? String != nil {
                                        print("Success Send Notification")
                                    } else {
                                        print("Send Notification Error")
                                    }
                                }
                            case .failure(let error):
                                print("FCM Topic Send Error : \(error)")
                                break
                            }
                        }
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///Push Notification을 위한 채팅방 구독
    func chattingMessageSubscribe(topics: [String]) {
        topics.forEach { topic in
            Messaging.messaging().subscribe(toTopic: topic)
        }
    }
    
    ///Push Notification 채팅방 구독 해제
    func chattingMessageUnsubscribe(topics: [String]) {
        topics.forEach { topic in
            Messaging.messaging().unsubscribe(fromTopic: topic)
        }
    }
}
