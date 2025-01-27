//
//  CommunityWritingViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/7/24.
//

import UIKit
import RxSwift
import RxCocoa

class CommunityWritingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let communityWritingViewModel = CommunityWritingViewModel()
    private let appearance = UINavigationBarAppearance()
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private let festivalContainerView = UIView()
    private let festivalLabel = UILabel()
    private let festivalButtonImageView = UIImageView()
    private let festivalContainerBottomDivider = UIView()
    
    private let textFieldContainerView = UIView()
    private let titleTextField = UITextField()
    private let detailTextView = UITextView()
    
    private var titleBool = false
    private var detailBool = false
    var post: Post?
    weak var delegate: CommunityWritingViewControllerDelegate?
    var festivalTitleReceived: ((String) -> Void)?
    var festivalIdReceived: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setBaseView()
        setFestivalView()
        setTextFieldView()
        setScrollByKeyboard()
        bindData()
        receiveFestivalClosure()
        setFestivalInEdit()
    }
    
    init(post: Post?) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
        //내비게이션바 설정
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        //내비게이션 아이템 설정
        navigationItem.backBarButtonItem?.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissSelf))
        navigationItem.leftBarButtonItem?.tintColor = .signatureTintColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(tappedComplete))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.signatureTintColor(), .font: UIFont.mainFontBold(size: 17.0)], for: .normal)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        //AutoLayout 설정
        scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollViewBottomConstraint.isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    //MARK: setFestivalView()
    ///같이갈 축제 선택지로 이동하는 버튼
    func setFestivalView() {
        //축제 이름
        festivalLabel.font = .mainFontRegular(size: 15.0)
        festivalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //이동 화살표 이미지
        festivalButtonImageView.image = UIImage(systemName: "chevron.forward")
        festivalButtonImageView.tintColor = .black
        festivalButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        
        festivalContainerBottomDivider.backgroundColor = .systemGray5
        festivalContainerBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        festivalContainerView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(tappedFestival))]
        
        festivalContainerView.addSubview(festivalLabel)
        festivalContainerView.addSubview(festivalButtonImageView)
        festivalContainerView.addSubview(festivalContainerBottomDivider)
        stackView.addArrangedSubview(festivalContainerView)
        
        //AutoLayout 설정
        festivalLabel.leadingAnchor.constraint(equalTo: festivalContainerView.leadingAnchor, constant: 24.0).isActive = true
        festivalLabel.topAnchor.constraint(equalTo: festivalContainerView.topAnchor, constant: 16.0).isActive = true
        festivalLabel.bottomAnchor.constraint(equalTo: festivalContainerView.bottomAnchor, constant: -16.0).isActive = true
        festivalLabel.trailingAnchor.constraint(lessThanOrEqualTo: festivalButtonImageView.leadingAnchor, constant: -16.0).isActive = true
        
        festivalButtonImageView.topAnchor.constraint(equalTo: festivalContainerView.topAnchor, constant: 16.0).isActive = true
        festivalButtonImageView.trailingAnchor.constraint(equalTo: festivalContainerView.trailingAnchor, constant: -24.0).isActive = true
        festivalButtonImageView.bottomAnchor.constraint(equalTo: festivalContainerView.bottomAnchor, constant: -16.0).isActive = true
        
        festivalContainerBottomDivider.leadingAnchor.constraint(equalTo: festivalContainerView.leadingAnchor, constant: 8.0).isActive = true
        festivalContainerBottomDivider.trailingAnchor.constraint(equalTo: festivalContainerView.trailingAnchor, constant: -8.0).isActive = true
        festivalContainerBottomDivider.bottomAnchor.constraint(equalTo: festivalContainerView.bottomAnchor).isActive = true
        festivalContainerBottomDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
    
    //MARK: setTextFieldView()
    ///제목, 내용 입력 텍스트필드뷰
    func setTextFieldView() {
        //제목 텍스트필드
        titleTextField.placeholder = "제목을 입력하세요."
        titleTextField.font = .mainFontBold(size: 17.0)
        titleTextField.text = post == nil ? nil : post?.title
        titleTextField.textColor = .black
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        //내용 텍스트필드
        detailTextView.delegate = self
        detailTextView.text = post == nil ? "내용을 입력하세요." : post?.detail
        detailTextView.font = .mainFontRegular(size: 15.0)
        detailTextView.textColor = post == nil ? .systemGray3 : .black
        detailTextView.isScrollEnabled = false
        detailTextView.translatesAutoresizingMaskIntoConstraints = false
        
        textFieldContainerView.addSubview(titleTextField)
        textFieldContainerView.addSubview(detailTextView)
        stackView.addArrangedSubview(textFieldContainerView)
        
        //AutoLayout 설정
        titleTextField.leadingAnchor.constraint(equalTo: textFieldContainerView.leadingAnchor, constant: 24.0).isActive = true
        titleTextField.topAnchor.constraint(equalTo: textFieldContainerView.topAnchor, constant: 16.0).isActive = true
        titleTextField.trailingAnchor.constraint(equalTo: textFieldContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        detailTextView.leadingAnchor.constraint(equalTo: textFieldContainerView.leadingAnchor, constant: 20.0).isActive = true
        detailTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor).isActive = true
        detailTextView.trailingAnchor.constraint(equalTo: textFieldContainerView.trailingAnchor, constant: -20.0).isActive = true
        detailTextView.bottomAnchor.constraint(equalTo: textFieldContainerView.bottomAnchor, constant: -8.0).isActive = true
        detailTextView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor).isActive = true
    }
    
    //MARK: setScrollByKeyboard()
    ///키보드 보임, 숨김 감지
    func setScrollByKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: setFestivalInEdit()
    ///'수정'으로 글쓰기뷰를 왔을 경우, 축제 이름과 id 데이터 바인딩
    func setFestivalInEdit() {
        if let post {
            self.communityWritingViewModel.festivalTitleSubject.onNext(post.festivalTitle)
            self.communityWritingViewModel.festivalIdSubject.onNext(post.festivalId)
        }
    }
    
    //MARK: receiveFestivalClosure()
    ///선택한 축제 이름과 id를 받아오는 클로저
    func receiveFestivalClosure() {
        festivalTitleReceived = { [weak self] title in
            self?.communityWritingViewModel.festivalTitleSubject.onNext(title)
        }
        festivalIdReceived = { [weak self] title in
            self?.communityWritingViewModel.festivalIdSubject.onNext(title)
        }
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //완료 버튼 활성화 Bool 데이터 바인딩
        communityWritingViewModel.isEnableCompleteButtonObservable
            .subscribe(onNext: { [weak self] in
                self?.navigationItem.rightBarButtonItem?.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
        //선택한 축제 데이터 바인딩
        communityWritingViewModel.festivalTitleSubject
            .map { $0 != nil ? $0 : "같이 가고싶은 축제를 선택하세요." }
            .bind(to: festivalLabel.rx.text)
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //제목 텍스트필드 텍스트 유무 Bool 데이터 바인딩
        titleTextField.rx.text.orEmpty
            .map { $0.count > 0 }
            .subscribe(onNext: { [weak self] in
                self?.communityWritingViewModel.isEmptyTitleSubject.onNext($0)
            })
            .disposed(by: disposeBag)
        
        //내용 텍스트필드 텍스트 유무 Bool 데이터 바인딩
        detailTextView.rx.text.orEmpty
            .map { $0.count > 0 && self.detailTextView.textColor == .black }
            .subscribe(onNext: { [weak self] in
                self?.communityWritingViewModel.isEmptyDetailSubject.onNext($0)
            })
            .disposed(by: disposeBag)
        
        //제목 텍스트필드 String 데이터 바인딩
        titleTextField.rx.text.orEmpty
            .bind(to: communityWritingViewModel.titleSubject)
            .disposed(by: disposeBag)
        
        //내용 텍스트필드 String 데이터 바인딩
        detailTextView.rx.text.orEmpty
            .bind(to: communityWritingViewModel.detailSubject)
            .disposed(by: disposeBag)
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///내비게이션 컨트롤러 Pop
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    ///글쓰기 완료
    @objc func tappedComplete() {
        //새로운 글쓰기일 때와 수정일 때
        if let post {
            communityWritingViewModel.editPost(postId: post.id)
            communityWritingViewModel.postObservableForViewFetch(postId: post.id)
                .subscribe(onNext: { [weak self] in
                    //게시글에 패치
                    self?.delegate?.fetchPostForView(post: $0)
                })
                .disposed(by: disposeBag)
        } else {
            communityWritingViewModel.uploadPost()
        }
        
        self.dismiss(animated: true)
    }
    
    ///축제 검색으로 이동
    @objc func tappedFestival() {
        let searchViewController = FestivalSearchViewController()
        
        navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    ///키보드가 나타날 때
    @objc func keyboardWillShow(_ notification: Notification) {
        //글쓰기 하단이 키보드 높이에 따라 올라감
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            scrollViewBottomConstraint.constant = -keyboardFrame.height
        }
    }
    
    ///키보드가 숨을 때
    @objc func keyboardWillHide(_ notification: Notification) {
        //글쓰기 하단 원상복구
        scrollViewBottomConstraint.constant = 0
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

extension CommunityWritingViewController: UITextViewDelegate {
    //텍스트 입력을 시작할 때, placeHolder 제거
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray3 {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    //텍스트 입력이 끝났을 때, placeHolder 생성
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "내용을 입력하세요."
            textView.textColor = .systemGray3
        }
    }
}

///게시글 수정 시, 수정된 내용 패치를 위한 델리게이트
protocol CommunityWritingViewControllerDelegate: AnyObject {
    func fetchPostForView(post: Post)
}
