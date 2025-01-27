//
//  ViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 9/9/24.
//

import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import NaverThirdPartyLogin

class SignInViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let signInViewModel: SignInViewModel = SignInViewModel()
    
    private var closeButtonConfig = UIButton.Configuration.plain()
    private let closeButton = UIButton()
    
    private var titleContainer = AttributeContainer()
    private let appleSignInButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton()
    private let googleSignInButton: GIDSignInButton = GIDSignInButton()
    private var naverButtonConfig = UIButton.Configuration.filled()
    private var kakaoButtonConfig = UIButton.Configuration.filled()
    private lazy var naverSignInButton: UIButton = UIButton(configuration: naverButtonConfig)
    private lazy var kakaoSignInButton: UIButton = UIButton(configuration: kakaoButtonConfig)
    
    var nicknameReceived: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setBaseView()
        setAppleSignInButton()
        setGoogleSignInButton()
        setNaverSignInButton()
        setKakaoSignInButton()
        bindData()
        
        nicknameReceived = { [weak self] nickname in
            self?.signInViewModel.nicknameSubject.onNext(nickname)
        }
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        titleContainer.font = UIFont.boldSystemFont(ofSize: 15)
        
        self.view.backgroundColor = .white
        
        //로그인 창 닫는 버튼
        closeButtonConfig.image = UIImage(systemName: "xmark.circle.fill")
        closeButtonConfig.baseForegroundColor = .lightGray
        closeButton.configuration = closeButtonConfig
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(closeButton)
        
        //AutoLayout 설정
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24.0).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        closeButton.centerXAnchor.constraint(greaterThanOrEqualTo: view.centerXAnchor).isActive = true
    }
    
    //MARK: setAppleSignInButton()
    ///애플 로그인 버튼
    func setAppleSignInButton() {
        self.appleSignInButton.addTarget(self, action: #selector(signInApple), for: .touchUpInside)
        self.appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(appleSignInButton)
        
        appleSignInButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        appleSignInButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: -120).isActive = true
        appleSignInButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 80).isActive = true
        appleSignInButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -80).isActive = true
        appleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    //MARK: setGoogleSignInButton()
    ///구글 로그인 버튼
    func setGoogleSignInButton() {
        self.googleSignInButton.style = .wide
        self.googleSignInButton.addTarget(self, action: #selector(signInGoogle), for: .touchUpInside)
        self.googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(googleSignInButton)
        
        googleSignInButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        googleSignInButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: -40).isActive = true
        googleSignInButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 80).isActive = true
        googleSignInButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -80).isActive = true
        googleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    //MARK: setNaverSignInButton()
    ///네이버 로그인 버튼
    func setNaverSignInButton() {
        self.naverButtonConfig.attributedTitle = AttributedString("네이버로 로그인", attributes: titleContainer)
        self.naverButtonConfig.image = UIImage(resource:.naverSymbol).resized(to: CGSize(width: 35, height: 35))
        self.naverButtonConfig.baseBackgroundColor = UIColor(hexCode: "03C75A")
        self.naverSignInButton.addTarget(self, action: #selector(signInNaver), for: .touchUpInside)
        self.naverSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(naverSignInButton)
        
        naverSignInButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        naverSignInButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: 40).isActive = true
        naverSignInButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 80).isActive = true
        naverSignInButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -80).isActive = true
        naverSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    //MARK: setKakaoSignInButton()
    ///카카오 로그인 버튼
    func setKakaoSignInButton() {
        self.kakaoButtonConfig.attributedTitle = AttributedString("카카오로 로그인", attributes: titleContainer)
        self.kakaoButtonConfig.image = UIImage(resource: .kakaoSymbol).resized(to: CGSize(width: 18, height: 18))
        self.kakaoButtonConfig.imagePadding = 8
        self.kakaoButtonConfig.baseForegroundColor = .black
        self.kakaoButtonConfig.baseBackgroundColor = UIColor(hexCode: "FEE500")
        self.kakaoSignInButton.addTarget(self, action: #selector(signInKakao), for: .touchUpInside)
        self.kakaoSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(kakaoSignInButton)
        
        kakaoSignInButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        kakaoSignInButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: 120).isActive = true
        kakaoSignInButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 80).isActive = true
        kakaoSignInButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -80).isActive = true
        kakaoSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //인증 결과 데이터 바인딩
        signInViewModel.authResultSubject
            .filter { $0 != nil }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] authResult in
                Task {
                    //첫 로그인일 때와 아닐 때
                    if await FirebaseFirestoreService.shared.isCheckUserData() {
                        let viewController =  NicknameSettingViewController()
                        let navigationController = UINavigationController(rootViewController: viewController)
                        
                        navigationController.modalPresentationStyle = .fullScreen
                        self?.present(navigationController, animated: true)
                    } else {
                        self?.signInViewModel.setUserInFirestore(authResult: authResult)
                        self?.dismiss(animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        //회원가입 정보 데이터 바인딩
        signInViewModel.signUpInfoObservable
            .subscribe(onNext: { [weak self] in
                self?.signInViewModel.setUserInFirestore(authResult: $0)
            })
            .disposed(by: disposeBag)
        
        //현재 사용자 데이터 바인딩
        FirebaseFirestoreService.shared.currentUserSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension SignInViewController {
    ///애플 로그인 이동
    @objc func signInApple() {
        self.signInViewModel.signInApplePresent(presenting: self)
    }
    
    ///구글 로그인 이동
    @objc func signInGoogle() {
        self.signInViewModel.signInGooglePresent(presenting: self)
    }
    
    ///네이버 로그인 이동
    @objc func signInNaver() {
        self.signInViewModel.signInNaverPresent(presenting: self)
    }
    
    ///카카오 로그인 이동
    @objc func signInKakao() {
        self.signInViewModel.signInKakaoPresent()
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        signInViewModel.appleAuthorizationError(error: error)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        signInViewModel.appleAuthorization(auth: authorization)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension SignInViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        signInViewModel.requestSignInNaver()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        signInViewModel.requestSignInNaver()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() { }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: (any Error)!) { }
}
