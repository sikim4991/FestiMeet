//
//  ChattingViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 11/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SideMenu

class ChattingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let appearance = UINavigationBarAppearance()
    private let chattingViewModel = ChattingViewModel()
    var chattingId: String?
    var otherId: String?
    
    private let tableView = UITableView()
    private var tableViewBottomConstraint: NSLayoutConstraint!
    
    private var reportAction: UIAction?
    private var copyAction: UIAction?
    
    private let chatTextContainerView = UIView()
    private let chatTextView = UITextView()
    private var sendButtonConfig = UIButton.Configuration.plain()
    private let sendButton = UIButton()
    private var chatTextContainerBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setTableView()
        setChatTextFieldView()
        setScrollByKeyboard()
        setUpdateLastReadDateWhenBackground()
        bindData()

    }
    
    deinit {
        print("deinit")
    }
    
    init(chattingId: String?, otherId: String?) {
        self.chattingId = chattingId
        self.otherId = otherId
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
        appearance.backgroundColor = UIColor.signatureBackgroundColor()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.signatureTintColor(), .font: UIFont.mainFontBold(size: 15.0)]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .white
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //내비게이션 아이템 설정
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .list), target: self, action: #selector (showSideMenu))
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(ChattingTableViewCell.self, forCellReuseIdentifier: "ChattingTableViewCell")
        tableView.separatorStyle = .none
        //스크롤 인디케이터 재배치
        tableView.verticalScrollIndicatorInsets = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: UIScreen.main.bounds.width - 9.0)
        //180도 회전
        tableView.transform = CGAffineTransform(rotationAngle: .pi)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        tableView.isUserInteractionEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        //AutoLayout 설정
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80.0)
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableViewBottomConstraint.isActive = true
    }
    
    //MARK: setChatTextFieldView()
    ///채팅 입력 텍스트필드뷰
    func setChatTextFieldView() {
        DispatchQueue.main.async { [weak self] in
            self?.chatTextContainerView.backgroundColor = .white
            self?.chatTextContainerView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        //채팅 텍스트 입력란
        chatTextView.delegate = self
        chatTextView.showsVerticalScrollIndicator = false
        chatTextView.text = "채팅을 입력하세요."
        chatTextView.textColor = .lightGray
        chatTextView.textContainerInset.left = 8.0
        chatTextView.textContainerInset.right = 40.0
        chatTextView.layer.cornerRadius = 12.0
        chatTextView.font = .mainFontRegular(size: 12.0)
        chatTextView.backgroundColor = .systemGray5
        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        
        //전송 버튼
        sendButtonConfig.image = UIImage(systemName: "paperplane.fill")
        sendButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .mainFontRegular(size: 12.0))
        sendButtonConfig.baseForegroundColor = .signatureTintColor()
        sendButton.configuration = sendButtonConfig
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        chatTextContainerView.addSubview(chatTextView)
        chatTextContainerView.addSubview(sendButton)
        view.addSubview(chatTextContainerView)
        
        //AutoLayout 설정
        chatTextContainerBottomConstraint = chatTextContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30.0)
        chatTextContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        chatTextContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        chatTextContainerBottomConstraint.isActive = true
        chatTextContainerView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        chatTextView.leadingAnchor.constraint(equalTo: chatTextContainerView.leadingAnchor, constant: 16.0).isActive = true
        chatTextView.trailingAnchor.constraint(equalTo: chatTextContainerView.trailingAnchor, constant: -16.0).isActive = true
        chatTextView.topAnchor.constraint(equalTo: chatTextContainerView.topAnchor, constant: 8.0).isActive = true
        chatTextView.bottomAnchor.constraint(equalTo: chatTextContainerView.bottomAnchor, constant: -8.0).isActive = true
        
        sendButton.centerYAnchor.constraint(equalTo: chatTextContainerView.centerYAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: chatTextView.trailingAnchor, constant: -4.0).isActive = true
    }
    
    //MARK: setScrollByKeyboard()
    ///키보드 보임, 숨김 감지
    func setScrollByKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //채팅방 이름 String 데이터 바인딩
        chattingViewModel.chattingSubject
            .map { $0.chattingName }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        //메시지 데이터 바인딩
        chattingViewModel.messagesSubject
            .map { $0.sorted(by: { $0.senderDate > $1.senderDate }) }
            .bind(to: tableView.rx.items(cellIdentifier: "ChattingTableViewCell", cellType: ChattingTableViewCell.self)) { [weak self] row, message, cell in
                guard let self else { return }
                cell.transform = CGAffineTransform(rotationAngle: .pi)
                cell.selectionStyle = .none
                
                do {
                    //본인 메시지인지 아닌지
                    if try FirebaseFirestoreService.shared.currentUserSubject.value()?.id == message.senderId {
                        cell.myMessageLabel.text = message.senderMessage
                        cell.myMessageDateLabel.text = self.chattingViewModel.dateConvert(date: message.senderDate)
                        cell.othersMessageLabel.isHidden = true
                        cell.othersNicknameLabel.isHidden = true
                        cell.othersMessageDateLabel.isHidden = true
                        cell.othersProfileImageView.isHidden = true
                        cell.othersMessageContainerView.isHidden = true
                    } else {
                        cell.othersMessageLabel.text = message.senderMessage
                        cell.othersMessageDateLabel.text = self.chattingViewModel.dateConvert(date: message.senderDate)
                        cell.othersNicknameLabel.text = self.chattingViewModel.senderNickname(otherId: message.senderId)
                        if let urlString = self.chattingViewModel.senderProfileImageURLString(otherId: message.senderId) {
                            cell.othersProfileImageView.kf.setImage(with: URL(string: urlString))
                        }
                        //신고 탭 클로저
                        cell.onResultReport = { [weak self] in
                            let alertController = UIAlertController(title: "신고하시겠습니까?", message: nil, preferredStyle: .alert)
                            let reportAction = UIAlertAction(title: "신고", style: .destructive) { [weak self] _ in
                                guard let self else { return }
                                self.chattingViewModel.reportUser(userId: message.senderId)
                                    .observe(on: MainScheduler.instance)
                                    .subscribe(onNext: { [weak self] in
                                        if $0 {
                                            let alertController = UIAlertController(title: "신고를 완료하였습니다.", message: nil, preferredStyle: .alert)
                                            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                                            alertController.addAction(okAction)
                                            self?.present(alertController, animated: true)
                                        } else {
                                            let alertController = UIAlertController(title: "신고를 실패하였습니다.", message: nil, preferredStyle: .alert)
                                            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                                            alertController.addAction(okAction)
                                            self?.present(alertController, animated: true)
                                        }
                                    })
                                    .disposed(by: self.disposeBag)
                            }
                            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                            
                            alertController.addAction(reportAction)
                            alertController.addAction(cancelAction)
                            
                            self?.present(alertController, animated: true)
                        }
                        cell.myMessageLabel.isHidden = true
                        cell.myMessageDateLabel.isHidden = true
                        cell.myMessageContainerView.isHidden = true
                    }
                } catch {
                    print("Error : \(error)")
                }
            }
            .disposed(by: disposeBag)
        
        //채팅 아이디 데이터 바인딩
        chattingViewModel.chattingIdSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if $0 == "exit" {
                    self?.dismissSelf()
                }
            })
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //otherId가 존재할 때 채팅방 생성
        if let otherId {
            chattingViewModel.loadExistChatting(otherId: otherId)
        }
        
        //chattingId가 존재할 때 기존 채팅방 패치
        if let chattingId {
            chattingViewModel.fetchChatting(chattingId: chattingId)
        }
        
        //텍스트필드 텍스트 유무 Bool 데이터 바인딩
        chatTextView.rx.text.orEmpty
            .map { [weak self] in
                $0.count > 0 && self?.chatTextView.textColor == .black
            }
            .subscribe(onNext: { [weak self] in
                self?.sendButton.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
        //텍스트필드 텍스트 String 데이터 바인딩
        chatTextView.rx.text.orEmpty
            .bind(to: chattingViewModel.messageTextSubject)
            .disposed(by: disposeBag)
        
        //전송 버튼 탭
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.chattingViewModel.sendMessage(otherId: self?.otherId)
                self?.chatTextView.text = nil
                self?.scrollToBottom()
            })
            .disposed(by: disposeBag)
        
        //메시지 Pagination 적용
        tableView.rx.prefetchRows
            .compactMap { $0.last?.row }
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { vc, row in
                row >= vc.chattingViewModel.newMessageCount + (vc.chattingViewModel.pageCount * vc.chattingViewModel.pageSize) - 1
            }
            .subscribe(onNext: { vc, row in
                vc.chattingViewModel.loadPastMessage()
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: scrollToBottom()
    ///마지막 메시지로 스크롤
    func scrollToBottom() {
        do {
            guard try chattingViewModel.messagesSubject.value().isEmpty == false else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } catch {
            print("Error : \(error)")
        }
    }
    
    ///키보드가 나타날 때
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            
            //채팅 하단이 키보드 높이에 맞춰 올라감
            tableViewBottomConstraint.constant = -keyboardFrame.height - 50.0
            chatTextContainerBottomConstraint.constant = -keyboardFrame.height
        }
    }
    
    ///키보드 숨김 때
    @objc func keyboardWillHide(_ notification: Notification) {
        //채팅 뷰 원상복구
        tableViewBottomConstraint.constant = -80.0
        chatTextContainerBottomConstraint.constant = -30.0
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///백그라운드 진입 때, 마지막으로 읽은 날짜 업데이트
    func setUpdateLastReadDateWhenBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLastReadDate), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    ///마지막 읽은 날짜 업데이트
    @objc private func updateLastReadDate() {
        chattingViewModel.updateLastReadDate()
    }
    
    ///빈 화면 터치시 키보드 숨김
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    ///사이드 메뉴 보여주기
    @objc func showSideMenu() {
        let sideMenuViewController = ChattingSideMenuViewController(chattingViewModel: chattingViewModel)
        let navigationController = ChattingSideMenuNavigationController(rootViewController: sideMenuViewController)
        
        self.present(navigationController, animated: true)
    }
    
    ///내비게이션 컨트롤러 Pop
    @objc func dismissSelf() {
        self.navigationController?.popViewController(animated: true)
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

extension ChattingViewController: UIGestureRecognizerDelegate {
    //뒤로가기 스와이프 제스쳐 활성화
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ChattingViewController: UITextViewDelegate {
    //텍스트필드 입력 시작했을 때, placeHolder 제거
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    //텍스트필드 입력 끝났을 때, 빈 텍스트면 placeHolder 생성
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "채팅을 입력하세요."
            textView.textColor = .lightGray
        }
    }
}

extension ChattingViewController: SideMenuNavigationControllerDelegate {
    //사이드 메뉴 나타나기 직전에 채팅방 투명도 조절
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        navigationController?.navigationBar.alpha = 0.5
        view.alpha = 0.5
    }
    
    //사이드 메뉴가 사라지기 전에 채팅방 투명도 원상복구
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        navigationController?.navigationBar.alpha = 1.0
        view.alpha = 1.0
    }
}
