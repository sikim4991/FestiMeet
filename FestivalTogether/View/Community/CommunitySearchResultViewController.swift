//
//  CommunitySearchResultViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/23/24.
//

import UIKit
import RxSwift
import RxCocoa

class CommunitySearchResultViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let communitySearchResultViewModel = CommunitySearchResultViewModel()
    private let appearance = UINavigationBarAppearance()
    var searchText: String
    private let tableView = UITableView()
    private var mainImageView = UIImageView()
    private var mainLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
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
        
        communitySearchResultViewModel.fetchSearchPost(searchText: searchText)
    }
    
    init(searchText: String) {
        self.searchText = searchText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .secondarySystemBackground
        
        //내비게이션 아이템 및 타이틀 설정
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.title = "\"\(searchText)\""
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "CommunitySearchResultTableViewCell")
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
    ///검색결과 아무것도 없을 때의 뷰
    func setEmptyView() {
        //돋보기 이미지
        mainImageView.image = UIImage(systemName: "exclamationmark.magnifyingglass")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 50.0))
        mainImageView.tintColor = .lightGray
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //레이블
        mainLabel.text = "검색결과가 없어요."
        mainLabel.textColor = .lightGray
        mainLabel.font = .mainFontBold(size: 15.0)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainImageView)
        view.addSubview(mainLabel)
        
        //AutoLayout 설정
        mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75.0).isActive = true
        mainImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        mainLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 8.0).isActive = true
        mainLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //검색결과 게시글 데이터 바인딩
        communitySearchResultViewModel.searchedPostSubject
            .bind(to: tableView.rx.items(cellIdentifier: "CommunitySearchResultTableViewCell", cellType: CommunityTableViewCell.self)) { [weak self] (row, post, cell) in
                let festivalTitleAttribute: NSMutableAttributedString
                let titleAttribute = NSMutableAttributedString(string: post.title)
                let detailAttribute = NSMutableAttributedString(string: post.detail)
                
                cell.resetCell()
                cell.selectionStyle = .none
                
                if let festivalTitle = post.festivalTitle {
                    festivalTitleAttribute = NSMutableAttributedString(string: festivalTitle)
                    festivalTitleAttribute.addAttribute(.foregroundColor, value: UIColor.signatureTintColor(), range: (festivalTitle.lowercased() as NSString).range(of: self?.searchText.lowercased() ?? ""))
                    cell.festivalLabel.attributedText = festivalTitleAttribute
                }
                titleAttribute.addAttribute(.foregroundColor, value: UIColor.signatureTintColor(), range: (post.title.lowercased() as NSString).range(of: self?.searchText.lowercased() ?? ""))
                detailAttribute.addAttribute(.foregroundColor, value: UIColor.signatureTintColor(), range: (post.detail.lowercased() as NSString).range(of: self?.searchText.lowercased() ?? ""))
                
                cell.titleLabel.attributedText = titleAttribute
                cell.detailLabel.attributedText = detailAttribute
                cell.dateLabel.text = self?.communitySearchResultViewModel.dateConvert(date: post.createdDate)
                cell.nicknameLabel.text = post.nickname
                cell.replyCountLabel.text = "\(post.replyCount)"
            }
            .disposed(by: disposeBag)
        
        //검색결과 게시글 유무 Bool 데이터 바인딩
        communitySearchResultViewModel.searchedPostSubject
            .map { !$0.isEmpty }
            .bind(to: mainLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        //검색결과 게시글 유무 Bool 데이터 바인딩
        communitySearchResultViewModel.searchedPostSubject
            .map { !$0.isEmpty }
            .bind(to: mainImageView.rx.isHidden)
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //게시글 선택 시 게시글로 이동
        tableView.rx.modelSelected(Post.self)
            .subscribe(onNext: { [weak self] in
                let viewController = CommunityDetailViewController(post: $0)
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        //게시글 Pagination 적용
        tableView.rx.prefetchRows
            .compactMap { $0.last?.row }
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { vc, row in
                return row >= vc.communitySearchResultViewModel.currentPostCount - 1
            }
            .subscribe(onNext: { [weak self] vc, row in
                guard let self else { return }
                vc.communitySearchResultViewModel.loadPageSearchPost(searchText: self.searchText)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: 뷰 관련 이외 메소드
    //내비게이션 컨트롤러 Pop
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
