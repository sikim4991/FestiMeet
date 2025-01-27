//
//  NotificationViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 1/9/25.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let notificationViewModel = NotificationViewModel()
    
    private let appearance = UINavigationBarAppearance()
    private let emptyLabel = UILabel()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setTableView()
        setEmptyView()
        bindData()
        updateNotificationCheckedDate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //내비게이션바 설정
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.signatureBackgroundColor()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.signatureTintColor(), .font: UIFont.mainFontBold(size: 15.0)]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .white
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //내비게이션 아이템 설정
        navigationController?.navigationBar.tintColor = .signatureTintColor()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.title = "알림"
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(NotificationTableViewCell.self , forCellReuseIdentifier: "NotificationTableViewCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        //AutoLayout 설정
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    //MARK: setEmptyView()
    ///알림이 비어있을 때 뷰
    func setEmptyView() {
        self.emptyLabel.text = "새로운 알림이 없어요."
        self.emptyLabel.font = .mainFontRegular(size: 15.0)
        self.emptyLabel.textColor = .secondaryLabel
        self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView.addSubview(self.emptyLabel)
        
        //AutoLayout 설정
        self.emptyLabel.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        self.emptyLabel.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor).isActive = true
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //새 알림 유무 Bool 데이터 바인딩
        notificationViewModel.notificationsObservable
            .map { !$0.isEmpty }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        //새 알림 데이터 바인딩
        notificationViewModel.notificationsObservable
            .bind(to: tableView.rx.items(cellIdentifier: "NotificationTableViewCell", cellType: NotificationTableViewCell.self)) { [weak self] row, notification, cell in
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.titleLabel.text = notification.title
                cell.bodyLabel.text = notification.body
                cell.receivedDateLabel.text = self?.notificationViewModel.convertDate(date: notification.receivedDate)
            }
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //알림 선택 시 해당 게시글로 이동 (게시글에 대한 알림에 한함)
        tableView.rx.modelSelected(UserNotification.self)
            .filter { $0.postId != nil }
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard let postId = $0.postId else { return }
                
                self.notificationViewModel.loadSelectedPost(postId: postId)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        let viewController = CommunityDetailViewController(post: $0)
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///새 알림 확인 날짜 업데이트
    func updateNotificationCheckedDate() {
        notificationViewModel.updateNotificationCheckedDate()
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

extension NotificationViewController: UIGestureRecognizerDelegate {
    //뒤로가기 스와이프 제스쳐 활성화
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
