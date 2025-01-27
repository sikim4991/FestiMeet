//
//  SignInViewModel.swift
//  FestivalTogether
//
//  Created by SIKim on 9/9/24.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import NaverThirdPartyLogin
import RxSwift
import AuthenticationServices
import CryptoKit
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxKakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

class SignInViewModel: NSObject {
    private let disposeBag = DisposeBag()
    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    ///한번만 사용되는 임의 암호화 String
    var currentNonce: String?
    
    var credentialSubject = BehaviorSubject<AuthCredential?>(value: nil)
    var naverSignInSubject = BehaviorSubject<NaverSignIn?>(value: nil)
    var authResultSubject = BehaviorSubject<AuthDataResult?>(value: nil)
    var nicknameSubject = BehaviorSubject<String?>(value: nil)
    
    lazy var signUpInfoObservable = Observable
        .combineLatest(authResultSubject, nicknameSubject)
        .filter { _, nickname in
            nickname != nil
        }
        .compactMap { authResult, nickname in
            authResult?.user.displayName = nickname
            return authResult
        }
    
    // MARK: - 애플 로그인 관련
    ///Nonce 암호화 String
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    ///SHA-256 Hash String
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    ///애플 로그인 시작
    func startSignInWithAppleFlow(viewController: UIViewController) {
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        currentNonce = nonce
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = viewController as? any ASAuthorizationControllerDelegate
        authorizationController.presentationContextProvider = viewController as? any ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
    
    ///애플 로그인 Present
    func signInApplePresent(presenting: UIViewController) {
        startSignInWithAppleFlow(viewController: presenting)
    }
    
    
    // MARK: - 구글 로그인 관련
    ///구글 로그인 Present
    func signInGooglePresent(presenting: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            guard error == nil else { return }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            
            self.credentialSubject.onNext(GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString))
            self.firebaseAuth(platform: "google")
        }
    }
    
    
    // MARK: - 네이버 로그인 관련
    ///네이버 로그인 Present
    func signInNaverPresent(presenting: UIViewController) {
        
        instance?.delegate = presenting as? any NaverThirdPartyLoginConnectionDelegate
        instance?.requestThirdPartyLogin()
    }
    
    ///네이버 로그인 요청
    func requestSignInNaver() {
        Observable<NaverSignIn>.create() { emitter in
            let urlString: String = "https://openapi.naver.com/v1/nid/me"
            guard let tokenType = self.instance?.tokenType else {
                return Disposables.create()
            }
            guard let accessToken = self.instance?.accessToken else {
                return Disposables.create()
            }
            guard let url = URL(string: urlString) else {
                return Disposables.create()
            }
            var request = URLRequest(url: url)
            
            
            request.httpMethod = "GET"
            request.setValue("\(tokenType) \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }
                
                if let data {
                    do {
                        let json = try JSONDecoder().decode(NaverSignIn.self, from: data)
                        emitter.onNext(json)
                    } catch {
                        emitter.onError(error)
                    }
                }
            }.resume()
            
            return Disposables.create()
        }
        .subscribe(onNext: {
            //네이버 로그인 패치 및 파이어베이스 인증
            self.naverSignInSubject.onNext($0)
            self.firebaseAuth(platform: "naver")
        })
        .disposed(by: disposeBag)
    }
    
    
    // MARK: - 카카오 로그인 관련
    ///카카오 로그인 Present
    func signInKakaoPresent() {
        //카카오톡 유무에 따른 로그인 환경
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext: { _ in
                    self.firebaseAuth(platform: "kakao")
                })
                .disposed(by: disposeBag)
        } else {
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(onNext: { _ in
                    self.firebaseAuth(platform: "kakao")
                })
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - 파이어베이스 인증
    ///로그인 정보를 통한 파이어베이스 인증
    func firebaseAuth(platform: String) {
        switch platform {
        case "apple", "google":
            self.credentialSubject.subscribe(onNext: {
                Auth.auth().signIn(with: $0!) { [weak self] authResult, error  in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    self?.authResultSubject.onNext(authResult)
                }
            })
            .disposed(by: disposeBag)
        case "naver":
            self.naverSignInSubject.subscribe(onNext: { [weak self] decodingData in
                guard let email = decodingData?.response.email, let password = decodingData?.response.id else {
                    print("Naver Data nil")
                    return
                }
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    guard authResult != nil else {
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            self?.authResultSubject.onNext(authResult)
                        }
                        return
                    }
                    self?.authResultSubject.onNext(authResult)
                }
            })
            .disposed(by: disposeBag)
        case "kakao":
            UserApi.shared.rx.me()
                .subscribe(onSuccess: { [weak self] decodingData in
                    var password = ""
                    guard let email = decodingData.kakaoAccount?.email, let passwordInt = decodingData.id else {
                        print("Kakao Data nil")
                        return
                    }
                    
                    password = String(passwordInt)
                    
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        guard authResult != nil else {
                            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                self?.authResultSubject.onNext(authResult)
                            }
                            return
                        }
                        self?.authResultSubject.onNext(authResult)
                    }
                })
                .disposed(by: disposeBag)
        default:
            break
        }
    }
    
    ///Firestore에 사용자 저장
    func setUserInFirestore(authResult: AuthDataResult) {
        UserDefaults.standard.set(authResult.user.uid, forKey: "UserID")
        Task {
            await FirebaseFirestoreService.shared.setUserData(nickname: authResult.user.displayName ?? "")
            FirebaseFirestoreService.shared.getUserData()
                .subscribe(onNext: {
                    FirebaseFirestoreService.shared.currentUserSubject.onNext($0)
                })
                .disposed(by: self.disposeBag)
        }
    }
}

extension SignInViewModel {
    ///애플 로그인 에러
    func appleAuthorizationError(error: any Error) {
        print(error.localizedDescription)
    }
    
    ///애플 로그인 인증
    func appleAuthorization(auth: ASAuthorization) {
        if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            self.credentialSubject.onNext(OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName))
            self.firebaseAuth(platform: "apple")
        }
    }
}

