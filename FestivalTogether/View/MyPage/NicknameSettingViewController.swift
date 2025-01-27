//
//  NicknameSettingViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/16/24.
//

import UIKit
import RxSwift
import RxCocoa

class NicknameSettingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let nicknameSettingViewModel = NicknameSettingViewModel()
    
    private let appearance = UINavigationBarAppearance()
    private let nicknameLabel = UILabel()
    private let nicknameTextField = UITextField()
    private let checkLabel = UILabel()
    private var checkButtonConfig = UIButton.Configuration.filled()
    private var checkButtonAttributedString = AttributedString("중복확인")
    private let checkButton = UIButton()
    
    private var resultNickname: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setNicknameView()
        bindData()
    }
    
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        //내비게이션바 설정
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        //내비게이션 아이템 설정
        navigationItem.backBarButtonItem?.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissSelf))
        navigationItem.leftBarButtonItem?.tintColor = .signatureTintColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(tappedComplete))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.signatureTintColor(), .font: UIFont.mainFontBold(size: 17.0)], for: .normal)
    }
    
    ///닉네임 입력 관련 뷰
    func setNicknameView() {
        //상단 '닉네임' 타이틀
        nicknameLabel.text = "닉네임"
        nicknameLabel.font = .mainFontBold(size: 12.0)
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //닉네임 입력 텍스트필드
        nicknameTextField.placeholder = "특수문자를 제외한 2-10글자"
        nicknameTextField.borderStyle = .roundedRect
        nicknameTextField.font = .mainFontRegular(size: 15.0)
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        //중복확인 버튼
        checkButtonAttributedString.font = .mainFontBold(size: 15.0)
        checkButtonConfig.baseBackgroundColor = .signatureBackgroundColor()
        checkButtonConfig.baseForegroundColor = .signatureTintColor()
        checkButtonConfig.attributedTitle = checkButtonAttributedString
        checkButton.configuration = checkButtonConfig
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        
        //중복확인 결과 레이블
        checkLabel.font = .mainFontRegular(size: 10.0)
        checkLabel.textColor = .clear
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(checkButton)
        view.addSubview(checkLabel)
        
        //AutoLayout 설정
        nicknameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24.0).isActive = true
        nicknameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100.0).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24.0).isActive = true
        
        nicknameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24.0).isActive = true
        nicknameTextField.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 4.0).isActive = true
        nicknameTextField.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        checkButton.leadingAnchor.constraint(equalTo: nicknameTextField.trailingAnchor, constant: 4.0).isActive = true
        checkButton.centerYAnchor.constraint(equalTo: nicknameTextField.centerYAnchor).isActive = true
        checkButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24.0).isActive = true
        
        checkLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32.0).isActive = true
        checkLabel.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 4.0).isActive = true
        checkLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //사용할 수 있는 닉네임 확인 Bool 데이터 바인딩
        nicknameSettingViewModel.isCorrectNicknameSubject
            .bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled)
            .disposed(by: disposeBag)
        
        nicknameSettingViewModel.isCorrectNicknameSubject
            .observe(on: MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { [weak self] in
                self?.checkLabel.textColor = $0 ? .black : .red
                self?.checkLabel.text = $0 ? "사용 가능한 닉네임이에요." : "이미 사용중인 닉네임이에요."
                self?.resultNickname = $0 ? self?.nicknameTextField.text : nil
            })
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //닉네임 텍스트필드 데이터 검열 (한글, 영문, 숫자)
        nicknameTextField.rx.text.orEmpty
            .map {
                let nicknameValidate = "[가-힣A-Za-z0-9]{2,10}"
                let pred = NSPredicate(format: "SELF MATCHES %@", nicknameValidate)
                return pred.evaluate(with: $0)
            }
            .bind(to: checkButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //중복확인 버튼 탭
        checkButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                nicknameSettingViewModel.checkNickname(nickname: self.nicknameTextField.text ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    ///내비게이션 컨트롤러 Pop
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    ///닉네임 데이터를 클로저를 통해 이전 뷰에 넘겨줌
    @objc func tappedComplete() {
        if let viewController = self.presentingViewController as? SignInViewController {
            viewController.nicknameReceived?(resultNickname ?? "")
            self.dismiss(animated: true)
        } else if let tabBarController = self.presentingViewController as? TabBarController {
            tabBarController.viewControllers?.forEach({ viewController in
                if let navigationController = viewController as? UINavigationController {
                    if let rootViewController = navigationController.viewControllers.first as? MyPageViewController {
                        rootViewController.nicknameReceived?(resultNickname ?? "")
                        self.dismiss(animated: true)
                    }
                }
            })
        }
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
