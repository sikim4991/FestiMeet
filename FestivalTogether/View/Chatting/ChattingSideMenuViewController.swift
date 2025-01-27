//
//  SideMenuViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 11/16/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ChattingSideMenuViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var chattingViewModel: ChattingViewModel
    
    private let titleContainerView = UIView()
    private let titleLabel = UILabel()
    
    private let tableView = UITableView()
    
    private let buttonContainerView = UIView()
    private var buttonAttributedString = AttributedString("채팅방 나가기")
    private var exitButtonConfig = UIButton.Configuration.plain()
    private let exitButton = UIButton()

    init(chattingViewModel: ChattingViewModel) {
        self.chattingViewModel = chattingViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setTitleView()
        setTableView()
        setButtonView()
        bindData()
    }
    
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .clear
    }
    
    ///사이드 메뉴 상단 타이틀뷰
    func setTitleView() {
        titleContainerView.backgroundColor = .white
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "채팅 참여자"
        titleLabel.font = .mainFontBold(size: 15.0)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleContainerView.addSubview(titleLabel)
        view.addSubview(titleContainerView)
        
        //AutoLayout 설정
        titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor, constant: 24.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor, constant: 16.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor, constant: -24.0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: -16.0).isActive = true
        
        titleContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        titleContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    ///TableView 관련
    func setTableView() {
        tableView.register(ChattingSideMenuTableViewCell.self, forCellReuseIdentifier: "ChattingSideMenuTableViewCell")
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        //AutoLayout 설정
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    ///채팅방 나가기 버튼
    func setButtonView() {
        buttonContainerView.backgroundColor = .signatureBackgroundColor()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonAttributedString.font = .mainFontBold(size: 12.0)
        exitButtonConfig.attributedTitle = buttonAttributedString
        exitButtonConfig.baseForegroundColor = .signatureTintColor()
        exitButtonConfig.image = UIImage(systemName: "rectangle.portrait.and.arrow.forward")
        exitButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .mainFontRegular(size: 12.0))
        exitButton.configuration = exitButtonConfig
        exitButton.addAction(UIAction(handler: { [weak self] _ in
            let alertController = UIAlertController(title: "채팅방에서 나가시겠습니까?", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "나가기", style: .destructive) { _ in
                self?.dismiss(animated: true) {
                    self?.chattingViewModel.exitChatting()
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self?.present(alertController, animated: true)
            
        }), for: .touchUpInside)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonContainerView.addSubview(exitButton)
        view.addSubview(buttonContainerView)
        
        //AutoLayout 설정
        exitButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: 24.0).isActive = true
        exitButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 16.0).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor, constant: -24.0).isActive = true
        exitButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor, constant: -50.0).isActive = true
        
        tableView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor).isActive = true
        buttonContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    ///데이터 바인딩
    func bindData() {
        //채팅 멤버 이미지 및 닉네임 데이터 바인딩
        chattingViewModel.chattingSubject
            .map { $0.members }
            .bind(to: tableView.rx.items(cellIdentifier: "ChattingSideMenuTableViewCell", cellType: ChattingSideMenuTableViewCell.self)) { row, member, cell in
                cell.selectionStyle = .none
                
                if let urlString = member.profileImageURLString {
                    cell.profileImageView.kf.setImage(with: URL(string: urlString))
                }
                cell.nicknameLabel.text = member.nickname
            }
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
