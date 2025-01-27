//
//  CommunityViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/7/24.
//

import UIKit
import RxSwift
import RxCocoa

///'게시판'탭 뷰
class CommunityViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let appearance = UINavigationBarAppearance()
    private let communityViewModel = CommunityViewModel()
    
    private let signInInfoLabel = UILabel()
    private var signInButtonConfig = UIButton.Configuration.filled()
    private var attributedString = AttributedString()
    private let signInButton = UIButton()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setTableView()
        setSignInButton()
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
        
        bindNotificationItem()
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .secondarySystemBackground
        
        //내비게이션 아이템 설정
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(resource: .plus), style: .plain, target: self, action: #selector(tappedWriting)),
            UIBarButtonItem(image: UIImage(resource: .notification), style: .plain, target: self, action: #selector(tappedNotification)),
            UIBarButtonItem(image: UIImage(resource: .search), style: .plain, target: self, action: #selector(tappedSearch))
        ]
        
        navigationController?.navigationBar.tintColor = .signatureTintColor()
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "CommunityTableViewCell")
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        //AutoLayout 설정
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //MARK: setSignInButton()
    ///로그인 버튼 관련
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
    
    //MARK: setEmptyView()
    ///게시글이 없을 경우 레이블 관련
    func setEmptyView() {
        self.emptyLabel.text = "첫 글을 게시해보세요."
        self.emptyLabel.font = .mainFontRegular(size: 15.0)
        self.emptyLabel.textColor = .secondaryLabel
        self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView.addSubview(self.emptyLabel)
        
        //AutoLayout 설정
        self.emptyLabel.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        self.emptyLabel.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor).isActive = true
    }
    
    //MARK: bindNotificationItem()
    ///알림 데이터 바인딩
    func bindNotificationItem() {
        //마지막 확인날짜 체크 데이터 바인딩
        communityViewModel.isCheckLastNotificationObservable
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                if $0 {
                    self?.navigationItem.rightBarButtonItems?[1].image = UIImage(resource: .notificationBadge)
                } else {
                    self?.navigationItem.rightBarButtonItems?[1].image = UIImage(resource: .notification)
                }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //로그인 여부 체크 관련 데이터 바인딩
        communityViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: (navigationController?.navigationBar.rx.isHidden)!)
            .disposed(by: disposeBag)
        
        communityViewModel.isSignInObservable
            .map { !$0 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        communityViewModel.isSignInObservable
            .bind(to: signInInfoLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        communityViewModel.isSignInObservable
            .bind(to: signInButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        communityViewModel.isSignInObservable
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.communityViewModel.fetchFirstPagePost()
            })
            .disposed(by: disposeBag)
        
        //게시글 데이터 바인딩
        communityViewModel.postSubject
            .bind(to: tableView.rx.items(cellIdentifier: "CommunityTableViewCell", cellType: CommunityTableViewCell.self)) { [weak self] (row, post, cell) in
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.festivalLabel.text = post.festivalTitle ?? "-"
                cell.titleLabel.text = post.title
                cell.detailLabel.text = post.detail
                cell.dateLabel.text = self?.communityViewModel.dateConvert(date: post.createdDate)
                cell.nicknameLabel.text = post.nickname
                cell.replyCountLabel.text = "\(post.replyCount)"
            }
            .disposed(by: disposeBag)
        
        //게시글 존재 여부 데이터 바인딩
        communityViewModel.postSubject
            .map { !$0.isEmpty }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        //계정 정지 여부 데이터 바인딩
        communityViewModel.isCheckReportUserObservable
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let alertController = UIAlertController(title: "계정 정지", message: "신고 누적으로 인해 계정이 정지되었습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.communityViewModel.signOut()
                }
                
                alertController.addAction(okAction)
                
                self?.navigationController?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //게시글 새로고침 (아래로 스와이프 제스쳐)
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] in
                self?.communityViewModel.fetchFirstPagePost()
                self?.tableView.refreshControl?.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        //게시글 Pagination 적용
        tableView.rx.prefetchRows
            .compactMap { $0.last?.row }
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { vc, row in
                return row >= vc.communityViewModel.currentPostCount - 1
            }
            .subscribe(onNext: { vc, row in
                vc.communityViewModel.loadPagePost()
            })
            .disposed(by: disposeBag)
        
        //게시글 선택 시, 해당 게시글로 이동
        tableView.rx.modelSelected(Post.self)
            .subscribe(onNext: { [weak self] in
                let viewController = CommunityDetailViewController(post: $0)
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///검색 뷰로 이동
    @objc func tappedSearch() {
        let viewController = FestivalSearchViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    ///알림 뷰로 이동
    @objc func tappedNotification() {
        let viewController = NotificationViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    ///글쓰기 뷰로 이동
    @objc func tappedWriting() {
        let communityWritingViewController = CommunityWritingViewController(post: nil)
        let communityWritingNavigationController = UINavigationController(rootViewController: communityWritingViewController)
        
        communityWritingNavigationController.modalPresentationStyle = .fullScreen
        present(communityWritingNavigationController, animated: true)
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
