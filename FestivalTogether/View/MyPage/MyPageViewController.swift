//
//  MyPageViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/7/24.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

class MyPageViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let appearance = UINavigationBarAppearance()
    private let myPageViewModel = MyPageViewModel()
    var nicknameReceived: ((String) -> Void)?
    
    private let profileContainerView = UIView()
    private let profileImageView = UIImageView()
    private let imagePicker = UIImagePickerController()
    private var nicknameAttributedString = AttributedString()
    private var nicknameChangeButtonConfig = UIButton.Configuration.plain()
    private let nicknameChangeButton = UIButton()
    private let emailLabel = UILabel()
    private var signInButtonConfig = UIButton.Configuration.filled()
    private var attributedString = AttributedString()
    private let signInButton = UIButton()
    private let profileContainerBottomDivider = UIView()
    
    private let spaceView = UIView()
    
    private let myPostContainerView = UIView()
    private let myPostImageView = UIImageView()
    private let myPostLabel = UILabel()
    
    private let myReplyContainerView = UIView()
    private let myReplyImageView = UIImageView()
    private let myReplyLabel = UILabel()
    
    private let privacyPolicyContainerView = UIView()
    private let privacyPolicyImageView = UIImageView()
    private let privacyPolicyLabel = UILabel()
    
    private let openSourceLicenseContainerView = UIView()
    private let openSourceLicenseImageView = UIImageView()
    private let openSourceLicenseLabel = UILabel()
    
    private let signOutContainerView = UIView()
    private let signOutLabel = UILabel()
    
    private let deleteIdContainerView = UIView()
    private let deleteIdLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setProfileView()
        setSpaceView()
        setListView()
        bindData()
        //닉네임 변경 시 받아오는 클로저
        nicknameReceived = { [weak self] nickname in
            self?.myPageViewModel.nicknameSubject.onNext(nickname)
            self?.myPageViewModel.changeNickname(nickname: nickname)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //내비게이션바 설정
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.signatureBackgroundColor()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        self.view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = .signatureTintColor()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        //AutoLayout 설정
        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    }
    
    //MARK: setProfileView()
    ///프로필 관련 뷰
    func setProfileView() {
        //프로필 이미지
        profileImageView.backgroundColor = .lightGray
        profileImageView.tintColor = .white
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor.systemGray5.cgColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeProfileImage(_:))))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        imagePicker.delegate = self
        
        //닉네임 버튼
        nicknameAttributedString.font = .mainFontBold(size: 12.0)
        nicknameChangeButtonConfig.image = UIImage(systemName: "pencil.line")
        nicknameChangeButtonConfig.contentInsets = .zero
        nicknameChangeButtonConfig.imagePlacement = .trailing
        nicknameChangeButtonConfig.attributedTitle = nicknameAttributedString
        nicknameChangeButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .mainFontRegular(size: 12.0))
        nicknameChangeButtonConfig.baseForegroundColor = .black
        nicknameChangeButton.configuration = nicknameChangeButtonConfig
        nicknameChangeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //이메일 레이블
        emailLabel.font = .mainFontRegular(size: 12.0)
        emailLabel.textColor = .black
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        profileContainerBottomDivider.backgroundColor = .systemGray5
        profileContainerBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        //로그인 버튼
        attributedString = AttributedString("로그인 하기")
        attributedString.font = .mainFontBold(size: 15.0)
        signInButtonConfig.baseBackgroundColor = .signatureBackgroundColor()
        signInButtonConfig.baseForegroundColor = .signatureTintColor()
        signInButtonConfig.attributedTitle = attributedString
        signInButton.configuration = signInButtonConfig
        signInButton.addAction(UIAction { [weak self] _ in
            let signInViewController = SignInViewController()
            signInViewController.modalPresentationStyle = .fullScreen
            self?.present(signInViewController, animated: true)
        }, for: .touchUpInside)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(nicknameChangeButton)
        profileContainerView.addSubview(emailLabel)
        profileContainerView.addSubview(signInButton)
        profileContainerView.addSubview(profileContainerBottomDivider)
        stackView.addArrangedSubview(profileContainerView)
        
        //AutoLayout 설정
        profileImageView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 24.0).isActive = true
        profileImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 16.0).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: profileContainerBottomDivider.topAnchor, constant: -16.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        
        nicknameChangeButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16.0).isActive = true
        nicknameChangeButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 24.0).isActive = true
        nicknameChangeButton.trailingAnchor.constraint(lessThanOrEqualTo: profileContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        emailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16.0).isActive = true
        emailLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -24.0).isActive = true
        emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: profileContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        signInButton.centerYAnchor.constraint(equalTo: profileContainerView.centerYAnchor).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor).isActive = true
        
        profileContainerBottomDivider.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor).isActive = true
        profileContainerBottomDivider.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor).isActive = true
        profileContainerBottomDivider.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor).isActive = true
        profileContainerBottomDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    //MARK: setSpaceView()
    ///프로필 컨테이너와 리스트 사이의 공백
    func setSpaceView() {
        spaceView.backgroundColor = .secondarySystemBackground
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(spaceView)
        
        spaceView.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    //MARK: setListView()
    ///메뉴 리스트 뷰
    func setListView() {
        //'내가 쓴 글'버튼 관련 뷰
        myPostLabel.text = "내가 쓴 글"
        myPostLabel.font = .mainFontBold(size: 12.0)
        myPostLabel.textColor = .black
        myPostLabel.translatesAutoresizingMaskIntoConstraints = false
        
        myPostImageView.image = UIImage(systemName: "chevron.forward")
        myPostImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .mainFontBold(size: 12.0))
        myPostImageView.tintColor = .black
        myPostImageView.translatesAutoresizingMaskIntoConstraints = false
        
        myPostContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedMyPost(_:))))
        myPostContainerView.isUserInteractionEnabled = true
        
        //'내가 쓴 댓글'버튼 관련 뷰
        myReplyLabel.text = "내가 쓴 댓글"
        myReplyLabel.font = .mainFontBold(size: 12.0)
        myReplyLabel.textColor = .black
        myReplyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        myReplyImageView.image = UIImage(systemName: "chevron.forward")
        myReplyImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .mainFontBold(size: 12.0))
        myReplyImageView.tintColor = .black
        myReplyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        myReplyContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedMyReply(_:))))
        myReplyContainerView.isUserInteractionEnabled = true
        
        //'개인정보 처리방침'버튼 관련 뷰
        privacyPolicyLabel.text = "개인정보 처리방침"
        privacyPolicyLabel.font = .mainFontBold(size: 12.0)
        privacyPolicyLabel.textColor = .black
        privacyPolicyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        privacyPolicyImageView.image = UIImage(systemName: "chevron.forward")
        privacyPolicyImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .mainFontBold(size: 12.0))
        privacyPolicyImageView.tintColor = .black
        privacyPolicyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        privacyPolicyContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedPrivacyPolicy(_:))))
        privacyPolicyContainerView.isUserInteractionEnabled = true
        
        //'오픈소스 라이센스'버튼 관련 뷰
        openSourceLicenseLabel.text = "오픈소스 라이센스"
        openSourceLicenseLabel.font = .mainFontBold(size: 12.0)
        openSourceLicenseLabel.textColor = .black
        openSourceLicenseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        openSourceLicenseContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenSourceLicense(_:))))
        openSourceLicenseContainerView.isUserInteractionEnabled = true
        
        openSourceLicenseImageView.image = UIImage(systemName: "chevron.forward")
        openSourceLicenseImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .mainFontBold(size: 12.0))
        openSourceLicenseImageView.tintColor = .black
        openSourceLicenseImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //'로그아웃'버튼 관련 뷰
        signOutLabel.text = "로그아웃"
        signOutLabel.font = .mainFontBold(size: 12.0)
        signOutLabel.textColor = .black
        signOutLabel.translatesAutoresizingMaskIntoConstraints = false
        
        signOutContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSignOut)))
        signOutContainerView.isUserInteractionEnabled = true
        
        //'회원탈퇴'버튼 관련 뷰
        deleteIdLabel.text = "회원탈퇴"
        deleteIdLabel.font = .mainFontBold(size: 12.0)
        deleteIdLabel.textColor = .red
        deleteIdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deleteIdContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedDeleteId)))
        deleteIdContainerView.isUserInteractionEnabled = true
        
        myPostContainerView.addSubview(myPostLabel)
        myPostContainerView.addSubview(myPostImageView)
        stackView.addArrangedSubview(myPostContainerView)
        
        myReplyContainerView.addSubview(myReplyLabel)
        myReplyContainerView.addSubview(myReplyImageView)
        stackView.addArrangedSubview(myReplyContainerView)
        
        privacyPolicyContainerView.addSubview(privacyPolicyLabel)
        privacyPolicyContainerView.addSubview(privacyPolicyImageView)
        stackView.addArrangedSubview(privacyPolicyContainerView)
        
        openSourceLicenseContainerView.addSubview(openSourceLicenseLabel)
        openSourceLicenseContainerView.addSubview(openSourceLicenseImageView)
        stackView.addArrangedSubview(openSourceLicenseContainerView)
        
        signOutContainerView.addSubview(signOutLabel)
        stackView.addArrangedSubview(signOutContainerView)
        
        deleteIdContainerView.addSubview(deleteIdLabel)
        stackView.addArrangedSubview(deleteIdContainerView)
        
        //AutoLayout 설정
        myPostLabel.leadingAnchor.constraint(equalTo: myPostContainerView.leadingAnchor, constant: 24.0).isActive = true
        myPostLabel.topAnchor.constraint(equalTo: myPostContainerView.topAnchor, constant: 24.0).isActive = true
        myPostLabel.bottomAnchor.constraint(equalTo: myPostContainerView.bottomAnchor, constant: -24.0).isActive = true
        
        myPostImageView.centerYAnchor.constraint(equalTo: myPostLabel.centerYAnchor).isActive = true
        myPostImageView.trailingAnchor.constraint(equalTo: myPostContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        myReplyLabel.leadingAnchor.constraint(equalTo: myReplyContainerView.leadingAnchor, constant: 24.0).isActive = true
        myReplyLabel.topAnchor.constraint(equalTo: myReplyContainerView.topAnchor, constant: 24.0).isActive = true
        myReplyLabel.bottomAnchor.constraint(equalTo: myReplyContainerView.bottomAnchor, constant: -24.0).isActive = true
        
        myReplyImageView.centerYAnchor.constraint(equalTo: myReplyLabel.centerYAnchor).isActive = true
        myReplyImageView.trailingAnchor.constraint(equalTo: myReplyContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        privacyPolicyLabel.leadingAnchor.constraint(equalTo: privacyPolicyContainerView.leadingAnchor, constant: 24.0).isActive = true
        privacyPolicyLabel.topAnchor.constraint(equalTo: privacyPolicyContainerView.topAnchor, constant: 24.0).isActive = true
        privacyPolicyLabel.bottomAnchor.constraint(equalTo: privacyPolicyContainerView.bottomAnchor, constant: -24.0).isActive = true
        
        privacyPolicyImageView.centerYAnchor.constraint(equalTo: privacyPolicyLabel.centerYAnchor).isActive = true
        privacyPolicyImageView.trailingAnchor.constraint(equalTo: privacyPolicyContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        openSourceLicenseLabel.leadingAnchor.constraint(equalTo: openSourceLicenseContainerView.leadingAnchor, constant: 24.0).isActive = true
        openSourceLicenseLabel.topAnchor.constraint(equalTo: openSourceLicenseContainerView.topAnchor, constant: 24.0).isActive = true
        openSourceLicenseLabel.bottomAnchor.constraint(equalTo: openSourceLicenseContainerView.bottomAnchor, constant: -24.0).isActive = true
        
        openSourceLicenseImageView.centerYAnchor.constraint(equalTo: openSourceLicenseLabel.centerYAnchor).isActive = true
        openSourceLicenseImageView.trailingAnchor.constraint(equalTo: openSourceLicenseContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        signOutLabel.leadingAnchor.constraint(equalTo: signOutContainerView.leadingAnchor, constant: 24.0).isActive = true
        signOutLabel.topAnchor.constraint(equalTo: signOutContainerView.topAnchor, constant: 24.0).isActive = true
        signOutLabel.bottomAnchor.constraint(equalTo: signOutContainerView.bottomAnchor, constant: -24.0).isActive = true
        
        deleteIdLabel.leadingAnchor.constraint(equalTo: deleteIdContainerView.leadingAnchor, constant: 24.0).isActive = true
        deleteIdLabel.topAnchor.constraint(equalTo: deleteIdContainerView.topAnchor, constant: 24.0).isActive = true
        deleteIdLabel.bottomAnchor.constraint(equalTo: deleteIdContainerView.bottomAnchor, constant: -24.0).isActive = true
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //프로필 이미지 데이터 바인딩
        myPageViewModel.profileImageURLStringSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] urlString in
                guard let urlString else {
                    self?.profileImageView.image = UIImage(resource: .person).withTintColor(.white)
                    return
                }
                guard let url = URL(string: urlString) else { return }
                self?.profileImageView.kf.setImage(with: url)
            })
            .disposed(by: disposeBag)
        
        //닉네임 데이터 바인딩
        myPageViewModel.nicknameSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] nickname in
                guard let nickname else { return }
                self?.nicknameAttributedString = .init(nickname)
                self?.nicknameAttributedString.font = .mainFontBold(size: 12.0)
                self?.nicknameChangeButtonConfig.attributedTitle = self?.nicknameAttributedString
                self?.nicknameChangeButton.configuration = self?.nicknameChangeButtonConfig
            })
            .disposed(by: disposeBag)
        
        //이메일 데이터 바인딩
        myPageViewModel.emailSubject
            .bind(to: emailLabel.rx.text)
            .disposed(by: disposeBag)
        
        //로그인 유무 Bool 데이터 바인딩
        myPageViewModel.isSignInObservable
            .bind(to: signInButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        myPageViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: nicknameChangeButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        myPageViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: emailLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        myPageViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: myPostContainerView.rx.isHidden)
            .disposed(by: disposeBag)
        
        myPageViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: myReplyContainerView.rx.isHidden)
            .disposed(by: disposeBag)
        
        myPageViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: signOutContainerView.rx.isHidden)
            .disposed(by: disposeBag)
        
        myPageViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: deleteIdContainerView.rx.isHidden)
            .disposed(by: disposeBag)
        
        //계정 정지 유무 Bool 데이터 바인딩
        myPageViewModel.isCheckReportUserObservable
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let alertController = UIAlertController(title: "계정 정지", message: "신고 누적으로 인해 계정이 정지되었습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.myPageViewModel.signOut()
                }
                
                alertController.addAction(okAction)
                
                self?.navigationController?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //닉네임 버튼을 눌렀을 때, 닉네임 설정 뷰로 이동
        nicknameChangeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let viewController =  NicknameSettingViewController()
                let navigationController = UINavigationController(rootViewController: viewController)
                
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///프로필 선택 시 메뉴 설정
    @objc func changeProfileImage(_ gesture: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "프로필 사진 선택", message: nil, preferredStyle: .actionSheet)
        let defaultImage = UIAlertAction(title: "기본 프로필 사진", style: .default) { [weak self] _ in
            self?.myPageViewModel.defaultProfileImage()
        }
        let pickImage = UIAlertAction(title: "앨범에서 선택", style: .default) { [weak self] _ in
            guard let self else { return }
            self.imagePicker.sourceType = .photoLibrary
            present(self.imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(defaultImage)
        alertController.addAction(pickImage)
        alertController.addAction(cancelAction)
        
        present(alertController,animated: true)
    }
    
    ///내가 쓴 글로 이동
    @objc func tappedMyPost(_ gesture: UITapGestureRecognizer) {
        let viewController = MyPostViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    ///내가 쓴 댓글로 이동
    @objc func tappedMyReply(_ gesture: UITapGestureRecognizer) {
        let viewController = MyReplyViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    ///개인정보 처리방침을 modal로 띄움
    @objc func tappedPrivacyPolicy(_ gesture: UITapGestureRecognizer) {
        guard let url = URL(string: "https://believed-galette-e2d.notion.site/179ee4b093b380cea3facac5d07732ec?pvs=4") else { return }
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }
    
    ///오픈소스 라이센스가 적혀있는 설정으로 이동
    @objc func tappedOpenSourceLicense(_ gesture: UITapGestureRecognizer) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    ///로그아웃 재확인 alert띄움
    @objc func tappedSignOut(_ gesture: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.myPageViewModel.signOut()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    ///아이디 삭제, 탈퇴 의사 재확인 alert띄움
    @objc func tappedDeleteId(_ gesture: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "정말 탈퇴하시겠습니까?", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "탈퇴", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.myPageViewModel.deleteId() { success in
                if success {
                    let alertController = UIAlertController(title: "탈퇴를 완료하였습니다.", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "확인", style: .default)
                    
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true)
                } else {
                    let alertController = UIAlertController(title: "탈퇴를 위해 재로그인이 필요합니다.", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "확인", style: .default)
                    
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MyPageViewController: UIGestureRecognizerDelegate {
    //뒤로가기 스와이프 제스쳐 활성화
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //이미지 선택 시, 프로필 이미지 업로드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myPageViewModel.uploadProfileImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
}
