//
//  NicknameSettingViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/16/24.
//

import Foundation
import RxSwift
import RxCocoa

class NicknameSettingViewModel {
    private let disposeBag = DisposeBag()
    
    ///올바른 닉네임 확인 Subject
    var isCorrectNicknameSubject = BehaviorSubject<Bool>(value: false)
    
    ///올바른 닉네임 확인 패치
    func checkNickname(nickname: String) {
        Task {
            isCorrectNicknameSubject.onNext(await FirebaseFirestoreService.shared.isCheckNickname(nickname: nickname))
        }
    }
}
