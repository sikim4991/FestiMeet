//
//  ChattingListViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/7/24.
//

import UIKit
import RxSwift
import RxCocoa

///'채팅'탭 뷰
class ChattingListViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let appearance = UINavigationBarAppearance()
    private let chattingListViewModel = ChattingListViewModel()
    var member: Member?
    
    private let signInInfoLabel = UILabel()
    private var signInButtonConfig = UIButton.Configuration.filled()
    private var attributedString = AttributedString()
    private let signInButton = UIButton()
    
    private let emptyLabel = UILabel()
    private let tableView = UITableView()
    
    init(member: Member?) {
        self.member = member
        super.init(nibName: nil, bundle: nil)
        bindBadgeValue()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setSignInButton()
        setTableView()
        setEmptyView()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        
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
        view.backgroundColor = .secondarySystemBackground
        
        navigationController?.navigationBar.tintColor = .signatureTintColor()
    }
    
    //MARK: setSignInButton()
    ///로그인 버튼
    func setSignInButton() {
        //로그인 필요 레이블
        signInInfoLabel.text = "로그인이 필요한 서비스에요."
        signInInfoLabel.font = .mainFontRegular(size: 15.0)
        signInInfoLabel.textColor = .gray
        signInInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        view.addSubview(signInInfoLabel)
        view.addSubview(signInButton)
        
        //AutoLayout 설정
        signInInfoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        signInInfoLabel.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -8.0).isActive = true
        
        signInButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        signInButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(ChattingListTableViewCell.self, forCellReuseIdentifier: "ChattingListTableViewCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        //AutoLayout 설정
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //MARK: setEmptyView()
    ///채팅방이 없을 때
    func setEmptyView() {
        self.emptyLabel.text = "진행중인 채팅이 없어요."
        self.emptyLabel.font = .mainFontRegular(size: 15.0)
        self.emptyLabel.textColor = .secondaryLabel
        self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView.addSubview(self.emptyLabel)
        
        //AutoLayout 설정
        self.emptyLabel.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        self.emptyLabel.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor).isActive = true
    }
    
    //MARK: bindBadgeValue()
    ///'채팅'탭 아이템 뱃지 데이터 바인딩
    func bindBadgeValue() {
        //MARK: OUTPUT
        //확인안한 채팅방 Bool 데이터 바인딩
        chattingListViewModel.chattingListSubject
            .map { ($0.map { $0.lastMessageDate ?? Date() }, $0.map { $0.members.filter { $0.userId == UserDefaults.standard.string(forKey: "UserID") }.first?.lastReadDate ?? Date() }) }
            .map {
                var chattingReadCount: Int = 0
                
                for (index, lastMessageDate) in $0.0.enumerated() {
                    if lastMessageDate > $0.1[index] {
                        chattingReadCount += 1
                    }
                }
                return chattingReadCount
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if $0 > 0 {
                    self?.tabBarItem.badgeValue = String($0)
                } else {
                    self?.tabBarItem.badgeValue = nil
                }
            })
            .disposed(by: disposeBag)
        
        //로그인 유무 Bool 데이터 바인딩
        chattingListViewModel.isSignInObservable
            .filter { $0 == false }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tabBarItem.badgeValue = nil
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //로그인 유무 Bool 데이터 바인딩
        chattingListViewModel.isSignInObservable
            .map { !$0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] bool in
                self?.navigationController?.navigationBar.isHidden = bool
            }
            .disposed(by: disposeBag)
        
        chattingListViewModel.isSignInObservable
            .bind(to: signInButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        chattingListViewModel.isSignInObservable
            .bind(to: signInInfoLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        chattingListViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        chattingListViewModel.chattingListSubject
            .map { !$0.isEmpty }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        //채팅방 리스트 데이터 바인딩
        chattingListViewModel.chattingListSubject
            .map { $0.sorted(by: { $0.lastMessageDate ?? Date() > $1.lastMessageDate ?? Date() }) }
            .bind(to: tableView.rx.items(cellIdentifier: "ChattingListTableViewCell", cellType: ChattingListTableViewCell.self)) { [weak self] (row, element, cell) in
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.chattingNameLabel.text = element.chattingName
                cell.chattingMemberCountLabel.text = "\(element.memberIds.count)"
                cell.lastMessageDateLabel.text = self?.chattingListViewModel.dateConvert(date: element.lastMessageDate ?? Date())
                cell.lastMessageLabel.text = element.lastMessage ?? "채팅을 입력해주세요."
                cell.chatImageView.image = UIImage(resource: .chat).withTintColor(element.lastMessageDate ?? Date() > element.members.filter { $0.userId == UserDefaults.standard.string(forKey: "UserID") }.first?.lastReadDate ?? Date() ? UIColor.signatureTintColor() : UIColor.lightGray)
                cell.chatImageView.layer.borderColor = element.lastMessageDate ?? Date() > element.members.filter { $0.userId == UserDefaults.standard.string(forKey: "UserID") }.first?.lastReadDate ?? Date() ? UIColor.signatureTintColor().cgColor : UIColor.lightGray.cgColor
            }
            .disposed(by: disposeBag)
        
        //계정 정지 확인 Bool 데이터 바인딩
        chattingListViewModel.isCheckReportUserObservable
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let alertController = UIAlertController(title: "계정 정지", message: "신고 누적으로 인해 계정이 정지되었습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.chattingListViewModel.signOut()
                }
                
                alertController.addAction(okAction)
                
                self?.navigationController?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //채팅방 선택 시, 초대 또는 채팅방으로 이동
        tableView.rx.modelSelected(Chatting.self)
            .subscribe(onNext: { [weak self] chatting in
                if let member = self?.member {
                    self?.chattingListViewModel.inviteChatting(chattingId: chatting.id, member: member)
                    self?.dismiss(animated: true)
                } else {
                    let viewController = ChattingViewController(chattingId: chatting.id, otherId: nil)
                    
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            })
            .disposed(by: disposeBag)
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
