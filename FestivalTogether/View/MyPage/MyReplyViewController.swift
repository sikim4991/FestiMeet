//
//  MyReplyViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/26/24.
//

import UIKit
import RxSwift
import RxCocoa

class MyReplyViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let myReplyViewModel = MyReplyViewModel()
    private let appearance = UINavigationBarAppearance()
    
    private let stackView = UIStackView()
    
    private let segmentContainerView = UIView()
    private let replyLabel = UILabel()
    private let replyBottomDivider = UIView()
    private let replyCommentLabel = UILabel()
    private let replyCommentBottomDivider = UIView()
    
    private let replyTableView = UITableView()
    private let replyCommentTableView = UITableView()
    
    private let emptyReplyLabel = UILabel()
    private let emptyReplyCommentLabel = UILabel()
    
    deinit {
        print("deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setSegmentView()
        setTableView()
        setEmptyView()
        bindData()
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
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .secondarySystemBackground
        
        //내비게이션 아이템 설정
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //MARK: setSegmentVieW()
    ///댓글, 대댓글 전환 버튼 뷰
    func setSegmentView() {
        segmentContainerView.backgroundColor = .signatureBackgroundColor()
        
        //댓글 버튼 관련
        replyLabel.text = "댓글"
        replyLabel.font = .mainFontExtraBold(size: 16.0)
        replyLabel.textColor = .signatureTintColor()
        replyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedReply)))
        replyLabel.isUserInteractionEnabled = true
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        replyBottomDivider.backgroundColor = .signatureTintColor()
        replyBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        //대댓글 버튼 관련
        replyCommentLabel.text = "대댓글"
        replyCommentLabel.font = .mainFontExtraBold(size: 16.0)
        replyCommentLabel.textColor = .lightGray
        replyCommentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedReplyComment)))
        replyCommentLabel.isUserInteractionEnabled = true
        replyCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        replyCommentBottomDivider.backgroundColor = .clear
        replyCommentBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        segmentContainerView.addSubview(replyLabel)
        segmentContainerView.addSubview(replyBottomDivider)
        segmentContainerView.addSubview(replyCommentLabel)
        segmentContainerView.addSubview(replyCommentBottomDivider)
        stackView.addArrangedSubview(segmentContainerView)
        
        //AutoLayout 설정
        replyLabel.topAnchor.constraint(equalTo: segmentContainerView.topAnchor, constant: 16.0).isActive = true
        replyLabel.centerXAnchor.constraint(equalTo: segmentContainerView.centerXAnchor, constant: -(view.bounds.width * 0.25)).isActive = true
        replyLabel.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor, constant: -16.0).isActive = true
        
        replyBottomDivider.leadingAnchor.constraint(equalTo: segmentContainerView.leadingAnchor).isActive = true
        replyBottomDivider.trailingAnchor.constraint(equalTo: segmentContainerView.centerXAnchor).isActive = true
        replyBottomDivider.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor).isActive = true
        replyBottomDivider.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        
        replyCommentLabel.topAnchor.constraint(equalTo: segmentContainerView.topAnchor, constant: 16.0).isActive = true
        replyCommentLabel.centerXAnchor.constraint(equalTo: segmentContainerView.centerXAnchor, constant: view.bounds.width * 0.25).isActive = true
        replyCommentLabel.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor, constant: -16.0).isActive = true
        
        replyCommentBottomDivider.leadingAnchor.constraint(equalTo: segmentContainerView.centerXAnchor).isActive = true
        replyCommentBottomDivider.trailingAnchor.constraint(equalTo: segmentContainerView.trailingAnchor).isActive = true
        replyCommentBottomDivider.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor).isActive = true
        replyCommentBottomDivider.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        replyTableView.register(MyReplyTableViewCell.self, forCellReuseIdentifier: "MyReplyTableViewCell")
        replyTableView.separatorStyle = .none
        
        replyCommentTableView.register(MyReplyTableViewCell.self, forCellReuseIdentifier: "MyReplyCommentTableViewCell")
        replyCommentTableView.separatorStyle = .none
        
        stackView.addArrangedSubview(replyTableView)
        stackView.addArrangedSubview(replyCommentTableView)
    }
    
    //MARK: setEmptyView()
    ///작성한 댓글이 없을 경우의 뷰
    func setEmptyView() {
        emptyReplyLabel.text = "작성한 댓글이 없어요."
        emptyReplyLabel.textColor = .secondaryLabel
        emptyReplyLabel.font = .mainFontRegular(size: 15.0)
        emptyReplyLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        emptyReplyCommentLabel.text = "작성한 댓글이 없어요."
//        emptyReplyCommentLabel.textColor = .secondaryLabel
//        emptyReplyCommentLabel.font = .mainFontRegular(size: 15.0)
//        emptyReplyCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyReplyLabel)
//        view.addSubview(emptyReplyCommentLabel)
        
        emptyReplyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        emptyReplyLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
//        emptyReplyCommentLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
//        emptyReplyCommentLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //내가 쓴 댓글 존재 여부 Bool 데이터 바인딩
        myReplyViewModel.isEmptyObservable
            .bind(to: emptyReplyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        //내가 쓴 댓글 데이터 바인딩
        myReplyViewModel.myReplySubject
            .bind(to: replyTableView.rx.items(cellIdentifier: "MyReplyTableViewCell", cellType: MyReplyTableViewCell.self)) { [weak self] (row, reply, cell) in
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.replyDetailLabel.text = reply.detail
                cell.dateLabel.text = self?.myReplyViewModel.dateConvert(date: reply.createdDate)
            }
            .disposed(by: disposeBag)
        
        //내가 쓴 대댓글 데이터 바인딩
        myReplyViewModel.myReplyCommentSubject
            .bind(to: replyCommentTableView.rx.items(cellIdentifier: "MyReplyCommentTableViewCell", cellType: MyReplyTableViewCell.self)) { [weak self] (row, replyComment, cell) in
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.replyDetailLabel.text = replyComment.detail
                cell.dateLabel.text = self?.myReplyViewModel.dateConvert(date: replyComment.createdDate)
            }
            .disposed(by: disposeBag)
        
        //댓글인지 대댓글인지 여부 Bool 데이터 바인딩
        myReplyViewModel.isReplySubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.replyLabel.textColor = $0 ? .signatureTintColor() : .lightGray
                self?.replyBottomDivider.backgroundColor = $0 ? .signatureTintColor() : .clear
                self?.replyCommentLabel.textColor = $0 ? .lightGray : .signatureTintColor()
                self?.replyCommentBottomDivider.backgroundColor = $0 ? .clear : .signatureTintColor()
            })
            .disposed(by: disposeBag)
        
        myReplyViewModel.isReplySubject
            .map { !$0 }
            .bind(to: replyTableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        myReplyViewModel.isReplySubject
            .bind(to: replyCommentTableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //Pagination 적용
        replyTableView.rx.prefetchRows
            .compactMap { $0.last?.row }
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { vc, row in
                return row >= vc.myReplyViewModel.currentReplyCount - 1
            }
            .subscribe(onNext: { vc, row in
                vc.myReplyViewModel.loadPageReply()
            })
            .disposed(by: disposeBag)
        
        //Pagination 적용
        replyCommentTableView.rx.prefetchRows
            .compactMap { $0.last?.row }
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { vc, row in
                return row >= vc.myReplyViewModel.currentReplyCommentCount - 1
            }
            .subscribe(onNext: { vc, row in
                vc.myReplyViewModel.loadPageReplyComment()
            })
            .disposed(by: disposeBag)
        
        //선택 시 해당 게시글로 이동
        replyTableView.rx.modelSelected(Reply.self)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.myReplyViewModel.loadSelectedPost(postId: $0.postId) { post in
                    guard let post else { return }
                    let viewController = CommunityDetailViewController(post: post)
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        //선택 시 해당 게시글로 이동
        replyCommentTableView.rx.modelSelected(ReplyComment.self)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.myReplyViewModel.loadSelectedPost(postId: $0.postId) { post in
                    guard let post else { return }
                    let viewController = CommunityDetailViewController(post: post)
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///댓글 리스트를 보여줌
    @objc func tappedReply() {
        myReplyViewModel.isReplySubject.onNext(true)
    }
    
    ///대댓글 리스트를 보여줌
    @objc func tappedReplyComment() {
        myReplyViewModel.isReplySubject.onNext(false)
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
