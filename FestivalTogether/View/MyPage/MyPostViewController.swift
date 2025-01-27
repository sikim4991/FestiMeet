//
//  MyPostViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/25/24.
//

import UIKit
import RxSwift
import RxCocoa

class MyPostViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let appearance = UINavigationBarAppearance()
    private let myPostViewModel = MyPostViewModel()
    private let tableView = UITableView()
    private let emptyLabel = UILabel()

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
    }
    
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .secondarySystemBackground
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
    }
    
    ///TableView 관련
    func setTableView() {
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "MyPostTableViewCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    ///작성한 글이 없을 경우의 뷰
    func setEmptyView() {
        emptyLabel.text = "작성한 글이 없어요."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .mainFontRegular(size: 15.0)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        
        emptyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //내가 쓴 글 데이터 바인딩
        myPostViewModel.myPostSubject
            .bind(to: tableView.rx.items(cellIdentifier: "MyPostTableViewCell", cellType: CommunityTableViewCell.self)) { [weak self] (row, post, cell) in
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.festivalLabel.text = post.festivalTitle
                cell.titleLabel.text = post.title
                cell.detailLabel.text = post.detail
                cell.dateLabel.text = self?.myPostViewModel.dateConvert(date: post.createdDate)
                cell.nicknameLabel.text = post.nickname
                cell.replyCountLabel.text = "\(post.replyCount)"
            }
            .disposed(by: disposeBag)
        
        //내가 쓴 글 존재여부 Bool 데이터 바인딩
        myPostViewModel.myPostSubject
            .map { !$0.isEmpty }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //Pagination 적용
        tableView.rx.prefetchRows
            .compactMap { $0.last?.row }
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { vc, row in
                return row >= vc.myPostViewModel.currentPostCount - 1
            }
            .subscribe(onNext: { vc, row in
                vc.myPostViewModel.loadPagePost()
            })
            .disposed(by: disposeBag)
        
        //선택한 게시글로 이동
        tableView.rx.modelSelected(Post.self)
            .subscribe(onNext: { [weak self] in
                let viewController = CommunityDetailViewController(post: $0)
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
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
