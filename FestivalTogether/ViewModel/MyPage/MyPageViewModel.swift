//
//  MyPageViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/23/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseMessaging
import RealmSwift

class MyPageViewModel {
    private let disposeBag = DisposeBag()
    ///닉네임 Subject
    var nicknameSubject = BehaviorSubject<String?>(value: nil)
    ///프로필 이미지 URL String Subject
    var profileImageURLStringSubject = BehaviorSubject<String?>(value: nil)
    ///로그인 이메일 Subject
    var emailSubject = BehaviorSubject<String?>(value: nil)
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
    
    init() {
        //사용자 데이터 패치
        if UserDefaults.standard.string(forKey: "UserID") != nil {
            FirebaseFirestoreService.shared.getUserData()
                .subscribe(onNext: {
                    FirebaseFirestoreService.shared.currentUserSubject.onNext($0)
                })
                .disposed(by: disposeBag)
        }
        
        //사용자 프로필이미지, 닉네임, 이메일 패치
        FirebaseFirestoreService.shared.currentUserSubject
            .subscribe(onNext: { [weak self] in
                self?.profileImageURLStringSubject.onNext($0?.profileImageURLString)
                self?.nicknameSubject.onNext($0?.nickname)
                self?.emailSubject.onNext($0?.email)
            })
            .disposed(by: disposeBag)
    }
    
    ///프로필 이미지 업로드
    func uploadProfileImage(image: UIImage) {
        FirebaseStorageService.shared.uploadImage(image: image)
    }
    
    ///기본 프로필 이미지로 리셋
    func defaultProfileImage() {
        FirebaseFirestoreService.shared.removeProfileImageURLString()
    }
    
    ///닉네임 변경
    func changeNickname(nickname: String) {
        nicknameSubject
            .take(1)
            .subscribe(onNext: { _ in
                Task {
                    await FirebaseFirestoreService.shared.updateNickname(nickname: nickname)
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
        
        Task {
            do {
                //토큰 및 User에 대한 정보 리셋
                try await Messaging.messaging().deleteToken()
                FirebaseFirestoreService.shared.currentUserSubject.onNext(nil)
                UserDefaults.standard.set(nil, forKey: "UserID")
            } catch {
                print("Messaging deleteToken error")
            }
        }
    }
    
    ///사용자 Id 삭제
    func deleteId(completion: @escaping (Bool) -> Void) {
        FirebaseFirestoreService.shared.removeUserData { [weak self] success in
            self?.signOut()
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
