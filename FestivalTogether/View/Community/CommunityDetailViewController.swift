//
//  CommunityDetailViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/11/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

class CommunityDetailViewController: UIViewController {
    private var disposeBag = DisposeBag()
    private let appearance = UINavigationBarAppearance()
    private let communityDetailViewModel = CommunityDetailViewModel()
    var post: Post
    
    //MARK: menuItems
    private lazy var menuItems: [UIAction] =
    //게시글이 본인이 작성한 것일때와 아닐때
    if post.userId == UserDefaults.standard.string(forKey: "UserID") {[
        //수정 메뉴
        UIAction(title: "수정", handler: { [weak self] _ in
            let communityWritingViewController = CommunityWritingViewController(post: self?.post)
            communityWritingViewController.delegate = self
            let communityWritingNavigationController = UINavigationController(rootViewController: communityWritingViewController)
            
            communityWritingNavigationController.modalPresentationStyle = .fullScreen
            self?.present(communityWritingNavigationController, animated: true)
        }),
        //삭제 메뉴
        UIAction(title: "삭제", attributes: .destructive, handler: { [weak self] _ in
            let alertController = UIAlertController(title: "삭제하시겠습니까?", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
                Task {
                    await self?.communityDetailViewModel.removePost(postId: self?.post.id ?? "")
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            self?.present(alertController, animated: true)
        })
    ]} else {[
        //채팅 보내기 메뉴
        UIAction(title: "채팅 보내기", handler: { [weak self] _ in
            let alertController = UIAlertController(title: "채팅 보내기", message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let createChattingAction = UIAlertAction(title: "새 채팅방 만들기", style: .default) { [weak self] _ in
                guard let self else { return }
                let viewController = ChattingViewController(chattingId: nil, otherId: self.post.userId)
                
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            let inviteChattingAction = UIAlertAction(title: "채팅방 초대하기", style: .default) { [weak self] _ in
                guard let self else { return }
                let viewController = ChattingListViewController(member: Member(userId: self.post.userId, nickname: self.post.nickname, profileImageURLString: self.post.profileImageURLString, startDate: Date(), lastReadDate: Date()))
                
                self.present(viewController, animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(createChattingAction)
            alertController.addAction(inviteChattingAction)
            
            self?.present(alertController, animated: true)
        }),
        //신고 메뉴
        UIAction(title: "신고", attributes: .destructive, handler: { [weak self] _ in
            let alertController = UIAlertController(title: "신고하시겠습니까?", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let reportAction = UIAlertAction(title: "신고", style: .destructive, handler: { [weak self] _ in
                guard let self else { return }
                self.communityDetailViewModel.reportPost(postId: self.post.id)
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
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(reportAction)
            
            self?.present(alertController, animated: true)
        })
    ]}
    private lazy var communityDetailCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        return collectionView
    }()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<ReplySection>?
    private var collectionViewBottomConstraint: NSLayoutConstraint!
    
    private let replyTextContainerView = UIView()
    private let replyTextView = UITextView()
    private var uploadButtonConfig = UIButton.Configuration.plain()
    private let uploadButton = UIButton()
    private var replyId: String?
    private var isTargetReplyComment: Bool = false
    private var replyTextContainerBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setBaseView()
        setCollectionView()
        setReplyTextFieldView()
        setScrollByKeyboard()
        bindData()
    }
    
    deinit {
        print("Commu deinit")
    }
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        //내비게이션바 설정
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.signatureBackgroundColor()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        self.communityDetailViewModel.fetchReply(postId: post.id)
        self.communityDetailViewModel.fetchReplyComment(postId: post.id)
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //내비게이션 아이템 설정
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(resource: .ellipsis),menu: UIMenu(children: menuItems))
    }
    
    //MARK: setCollecitonView()
    ///컬렉션뷰 관련
    func setCollectionView() {
        //컬렉션뷰에 각 셀 및 리유저블뷰 등록
        communityDetailCollectionView.register(ReplyCountCollectionViewCell.self, forCellWithReuseIdentifier: "ReplyCountCollectionViewCell")
        communityDetailCollectionView.register(PostCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PostCollectionReusableView")
        communityDetailCollectionView.register(ReplyCommentCollectionViewCell.self, forCellWithReuseIdentifier: "ReplyCommentCollectionViewCell")
        communityDetailCollectionView.register(ReplyCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ReplyCollectionReusableView")
        communityDetailCollectionView.backgroundColor = .white
        communityDetailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        dataSource = RxCollectionViewSectionedReloadDataSource<ReplySection>(configureCell: { [weak self] dataSource, collectionView, indexPath, item in
            //리유저블뷰 하단에 생성되는 뷰
            guard let self else { return UICollectionViewCell() }
            if indexPath.section > 0 {  //섹션 1이상일 때 (대댓글)
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReplyCommentCollectionViewCell", for: indexPath) as? ReplyCommentCollectionViewCell else { return UICollectionViewCell() }
                var menuItems: [UIAction] = []
                
                //본인 댓글인지 여부에 따라 메뉴 설정
                if item.userId == UserDefaults.standard.string(forKey: "UserID") {
                    //삭제 메뉴
                    menuItems.append(UIAction(title: "삭제", attributes: .destructive) { [weak self] _ in
                        let alertController = UIAlertController(title: "삭제하시겠습니까?", message: nil, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
                            guard let self else { return }
                            self.communityDetailViewModel.removeReplyComment(replyComment: item)
                            self.communityDetailViewModel.fetchReplyComment(postId: self.post.id)
                        })
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(deleteAction)
                        
                        self?.present(alertController, animated: true)
                    })
                } else {
                    //채팅 보내기 메뉴
                    menuItems.append(UIAction(title: "채팅 보내기") { [weak self] _ in
                        let alertController = UIAlertController(title: "채팅 보내기", message: nil, preferredStyle: .actionSheet)
                        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                        let createChattingAction = UIAlertAction(title: "새 채팅방 만들기", style: .default) { [weak self] _ in
                            let viewController = ChattingViewController(chattingId: nil, otherId: item.userId)
                            
                            self?.navigationController?.pushViewController(viewController, animated: true)
                        }
                        let inviteChattingAction = UIAlertAction(title: "채팅방 초대하기", style: .default) { [weak self] _ in
                            let viewController = ChattingListViewController(member: Member(userId: item.userId, nickname: item.nickname, profileImageURLString: nil, startDate: Date(), lastReadDate: Date()))
                            
                            self?.present(viewController, animated: true)
                        }
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(createChattingAction)
                        alertController.addAction(inviteChattingAction)
                        
                        self?.present(alertController, animated: true)
                    })
                    //신고 메뉴
                    menuItems.append(UIAction(title: "신고", attributes: .destructive) { [weak self] _ in
                        let alertController = UIAlertController(title: "신고하시겠습니까?", message: nil, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                        let reportAction = UIAlertAction(title: "신고", style: .destructive, handler: { [weak self] _ in
                            guard let self else { return }
                            self.communityDetailViewModel.reportReplyComment(replyCommentId: item.id)
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
                        })
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(reportAction)
                        
                        self?.present(alertController, animated: true)
                    })
                }
                
                //대댓글 셀 뷰 관련
                cell.replyCommentNicknameLabel.text = item.nickname
                cell.replyCommentNicknameLabel.textColor = item.userId == UserDefaults.standard.string(forKey: "UserID") ? .signatureTintColor() : .black
                cell.replyCommentDateLabel.text = communityDetailViewModel.convertDate(date: item.createdDate)
                cell.replyCommentDetailLabel.text = item.detail
                cell.replyCommentOthersButton.menu = UIMenu(children: menuItems)
                cell.replyCommentOthersButton.showsMenuAsPrimaryAction = true
                
                return cell
            } else {    //색션 0일 때 (댓글 수)
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReplyCountCollectionViewCell", for: indexPath) as? ReplyCountCollectionViewCell else { return UICollectionViewCell() }
                
                communityDetailViewModel.replyCountObservable
                    .map {
                        "댓글 \($0)개"
                    }
                    .bind(to: cell.replyCountLabel.rx.text)
                    .disposed(by: disposeBag)
                
                return cell
            }
        }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            //셀 상단에 생성되는 뷰
            guard let self else { return UICollectionReusableView() }
            if indexPath.section > 0 {  //색션 1이상일 때 (댓글)
                let replyView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ReplyCollectionReusableView", for: indexPath) as! ReplyCollectionReusableView
                let section = dataSource.sectionModels[indexPath.section]
                var menuItems: [UIAction] = [UIAction(title: "댓글달기") { [weak self] _ in
                    self?.isTargetReplyComment = true
                    self?.replyId = section.header.id
                    self?.replyTextView.becomeFirstResponder()
                }]
                
                //본인이 작성한 글인지 여부에 따라 메뉴 설정
                if section.header.userId == UserDefaults.standard.string(forKey: "UserID") {
                    //삭제 메뉴
                    menuItems.append(UIAction(title: "삭제", attributes: .destructive) { [weak self] _ in
                        let alertController = UIAlertController(title: "삭제하시겠습니까?", message: nil, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
                            guard let self else { return }
                            Task {
                                await self.communityDetailViewModel.removeReply(reply: section.header)
                                self.communityDetailViewModel.fetchReply(postId: self.post.id)
                                self.communityDetailViewModel.fetchReplyComment(postId: self.post.id)
                            }
                        })
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(deleteAction)
                        
                        self?.present(alertController, animated: true)
                    })
                } else {
                    //채팅 보내기 메뉴
                    menuItems.append(UIAction(title: "채팅 보내기") { [weak self] _ in
                        let alertController = UIAlertController(title: "채팅 보내기", message: nil, preferredStyle: .actionSheet)
                        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                        let createChattingAction = UIAlertAction(title: "새 채팅방 만들기", style: .default) { [weak self] _ in
                            let viewController = ChattingViewController(chattingId: nil, otherId: section.header.userId)
                            
                            self?.navigationController?.pushViewController(viewController, animated: true)
                        }
                        let inviteChattingAction = UIAlertAction(title: "채팅방 초대하기", style: .default) { [weak self] _ in
                            let viewController = ChattingListViewController(member: Member(userId: section.header.userId, nickname: section.header.nickname, profileImageURLString: nil, startDate: Date(), lastReadDate: Date()))
                            
                            self?.present(viewController, animated: true)
                        }
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(createChattingAction)
                        alertController.addAction(inviteChattingAction)
                        
                        self?.present(alertController, animated: true)
                    })
                    //신고 메뉴
                    menuItems.append(UIAction(title: "신고", attributes: .destructive) { [weak self] _ in
                        let alertController = UIAlertController(title: "신고하시겠습니까?", message: nil, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                        let reportAction = UIAlertAction(title: "신고", style: .destructive, handler: { [weak self] _ in
                            guard let self else { return }
                            self.communityDetailViewModel.reportReply(replyId: section.header.id)
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
                        })
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(reportAction)
                        
                        self?.present(alertController, animated: true)
                    })
                }
                
                //댓글 리유저블뷰 관련
                replyView.replyNicknameLabel.text = section.header.nickname
                replyView.replyNicknameLabel.textColor = section.header.userId == UserDefaults.standard.string(forKey: "UserID") ? .signatureTintColor() : .black
                replyView.replyDateLabel.text = self.communityDetailViewModel.convertDate(date: section.header.createdDate)
                replyView.replyDetailLabel.text = section.header.detail
                replyView.replyOthersButton.menu = UIMenu(children: menuItems)
                replyView.replyOthersButton.showsMenuAsPrimaryAction = true
                
                return replyView
            } else {
                let postView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PostCollectionReusableView", for: indexPath) as! PostCollectionReusableView
                
                //게시글 리유저블뷰 관련
                if let urlString = self.post.profileImageURLString {
                    postView.profileImageView.kf.setImage(with: URL(string: urlString))
                }
                postView.nicknameLabel.text = self.post.nickname
                postView.createdDateLabel.text = self.communityDetailViewModel.convertDate(date: self.post.createdDate)
                postView.titleLabel.text = self.post.title
                postView.detailLabel.text = self.post.detail
                if let festivalTitle = self.post.festivalTitle, let _ = self.post.festivalId {
                    postView.festivalButton.setAttributedTitle(NSAttributedString(string: festivalTitle, attributes: [
                        .font: UIFont.mainFontBold(size: 12.0),
                        .foregroundColor: UIColor.black
                    ]), for: .normal)
                    
                    postView.festivalButton.addTarget(self, action: #selector(tappedFestivalButton), for: .touchUpInside)
                } else {
                    postView.festivalButton.isHidden = true
                }
                
                return postView
            }
        })
        
        view.addSubview(communityDetailCollectionView)
        
        //AutoLayout 설정
        collectionViewBottomConstraint = communityDetailCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80.0)
        communityDetailCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        communityDetailCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        communityDetailCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionViewBottomConstraint.isActive = true
    }
    
    //MARK: setReplyTextFieldView()
    ///댓글 텍스트필드뷰
    func setReplyTextFieldView() {
        DispatchQueue.main.async { [weak self] in
            self?.replyTextContainerView.backgroundColor = .white
            self?.replyTextContainerView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        //텍스트필드뷰
        replyTextView.delegate = self
        replyTextView.showsVerticalScrollIndicator = false
        replyTextView.text = "댓글을 입력하세요."
        replyTextView.textColor = .lightGray
        replyTextView.textContainerInset.left = 8.0
        replyTextView.textContainerInset.right = 40.0
        replyTextView.layer.cornerRadius = 12.0
        replyTextView.font = .mainFontRegular(size: 12.0)
        replyTextView.backgroundColor = .systemGray5
        replyTextView.translatesAutoresizingMaskIntoConstraints = false
        
        //업로드 버튼
        uploadButtonConfig.image = UIImage(systemName: "paperplane.fill")
        uploadButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .mainFontRegular(size: 12.0))
        uploadButtonConfig.baseForegroundColor = .signatureTintColor()
        uploadButton.configuration = uploadButtonConfig
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        
        replyTextContainerView.addSubview(replyTextView)
        replyTextContainerView.addSubview(uploadButton)
        view.addSubview(replyTextContainerView)
        
        //AutoLayout 설정
        replyTextContainerBottomConstraint = replyTextContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30.0)
        replyTextContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        replyTextContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        replyTextContainerBottomConstraint.isActive = true
        replyTextContainerView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        replyTextView.leadingAnchor.constraint(equalTo: replyTextContainerView.leadingAnchor, constant: 16.0).isActive = true
        replyTextView.trailingAnchor.constraint(equalTo: replyTextContainerView.trailingAnchor, constant: -16.0).isActive = true
        replyTextView.topAnchor.constraint(equalTo: replyTextContainerView.topAnchor, constant: 8.0).isActive = true
        replyTextView.bottomAnchor.constraint(equalTo: replyTextContainerView.bottomAnchor, constant: -8.0).isActive = true
        
        uploadButton.centerYAnchor.constraint(equalTo: replyTextContainerView.centerYAnchor).isActive = true
        uploadButton.trailingAnchor.constraint(equalTo: replyTextView.trailingAnchor, constant: -4.0).isActive = true
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
        guard let dataSource else { return }
        //MARK: OUTPUT
        //댓글 데이터 바인딩
        communityDetailViewModel.replySectionObservable
            .bind(to: communityDetailCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //댓글 텍스트필드 String 데이터 바인딩
        replyTextView.rx.text.orEmpty
            .bind(to: communityDetailViewModel.replyStringSubject)
            .disposed(by: disposeBag)
        
        //댓글 텍스트필드에 입력 여부에 따른 Bool 데이터 바인딩
        replyTextView.rx.text.orEmpty
            .map { [weak self] in
                $0.count > 0 && self?.replyTextView.textColor == .black
            }
            .subscribe(onNext: { [weak self] in
                self?.uploadButton.isEnabled = $0
            })
            .disposed(by: disposeBag)
        
        //업로드 시, 댓글 목적인지 대댓글 목적인지 여부 판별
        uploadButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if self.isTargetReplyComment {
                    self.communityDetailViewModel.uploadReplyComment(post: post, replyId: replyId ?? "")
                    self.replyTextView.text = nil
                    self.communityDetailViewModel.fetchReplyComment(postId: self.post.id)
                } else {
                    self.communityDetailViewModel.uploadReply(post: self.post)
                    self.replyTextView.text = nil
                    self.communityDetailViewModel.fetchReply(postId: self.post.id)
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: createLayout()
    ///컬렉션뷰 레이아웃 설정 관련
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            //헤더 설정
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            //Sticky Header 비활성화
            header.pinToVisibleBounds = false
            
            //섹션 설정
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            //헤더 추가
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///키보드가 보여질 시점에 발생하는 메소드
    @objc func keyboardWillShow(_ notification: Notification) {
        //키보드 높이에 맞춰 댓글 입력뷰와 게시글뷰가 올라감
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            
            collectionViewBottomConstraint.constant = -keyboardFrame.height - 50.0
            replyTextContainerBottomConstraint.constant = -keyboardFrame.height
        }
    }
    
    ///키보드가 숨겨질 시점에 발생하는 메소드
    @objc func keyboardWillHide(_ notification: Notification) {
        //댓글 입력뷰와 게시글뷰가 내려감
        collectionViewBottomConstraint.constant = -80.0
        replyTextContainerBottomConstraint.constant = -30.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            //대댓글 목적인지 확인하는 프로퍼티 리셋
            self?.isTargetReplyComment = false
        }
    }
    
    ///내비게이션 컨트롤러 Pop
    @objc func dismissSelf() {
        navigationController?.popViewController(animated: true)
    }
    
    ///축제 정보로 이동
    @objc func tappedFestivalButton() {
        if let _ = self.post.festivalTitle, let festivalId = self.post.festivalId {
            let viewController = FestivalDetailViewController(contentId: festivalId)
            
            navigationController?.pushViewController(viewController, animated: true)
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

extension CommunityDetailViewController: UITextViewDelegate {
    //텍스트 수정이 시작되었을 때 placeHolder가 있으면, 빈 텍스트와 텍스트 컬러 변경
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    //텍스트 수정이 끝났을 때 비어있으면 placeHolder 활성화
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "댓글을 입력하세요."
            textView.textColor = .lightGray
        }
    }
}

//커스텀 델리게이트 패턴
extension CommunityDetailViewController: CommunityWritingViewControllerDelegate {
    ///수정된 게시글을 패치
    func fetchPostForView(post: Post) {
        self.post = post
        DispatchQueue.main.async {
            self.communityDetailCollectionView.reloadData()
        }
    }
}

extension CommunityDetailViewController: UIGestureRecognizerDelegate {
    //뒤로가기 제스쳐 활성화
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: 컬렉션뷰를 위한 struct/section정의
struct PostSection {
    var header: Post
    var items: [Int]
}

extension PostSection: SectionModelType {
    typealias Item = Int
    
    init(original: PostSection, items: [Int]) {
        self = original
        self.items = items
    }
}

struct ReplySection {
    var header: Reply
    var items: [ReplyComment]
}

extension ReplySection: SectionModelType {
    typealias Item = ReplyComment
    
    init(original: ReplySection, items: [ReplyComment]) {
        self = original
        self.items = items
    }
}
