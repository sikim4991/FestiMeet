//
//  FestivalSearchViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/2/24.
//

import UIKit
import RxSwift
import RxCocoa

//축제검색 뷰
class FestivalSearchViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var tableViewDisposable: Disposable?
    private let festivalSearchViewModel = FestivalSearchViewModel()
    
    private let appearance = UINavigationBarAppearance()
    private let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 0))
    private var searchTextForColor = ""
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setTableView()
        bindData()
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
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .secondarySystemBackground
        
        self.hideKeyboardWhenTappedAround()
        
        //searchBar 설정
        searchBar.tintColor = .signatureTintColor()
        searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        
        //내비게이션 컨트롤러 시작점에 따라 searchBar 텍스트 필드가 바뀜
        if navigationController?.viewControllers.first is FestivalListViewController {
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "가보고 싶은 축제 검색!", attributes: [.font: UIFont.mainFontRegular(size: 12.0)])
        } else if navigationController?.viewControllers.first is CommunityWritingViewController {
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "같이 가고싶은 축제를 선택하세요!", attributes: [.font: UIFont.mainFontRegular(size: 12.0)])
        } else if navigationController?.viewControllers.first is CommunityViewController {
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "검색할 축제를 선택하세요.", attributes: [.font: UIFont.mainFontRegular(size: 12.0)])
        }
        
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        //내비게이션 아이템 설정
        navigationController?.navigationBar.tintColor = .signatureTintColor()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.titleView = searchBar
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(FestivalSearchTableViewCell.self, forCellReuseIdentifier: "FestivalSearchTableViewCell")
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        //AutoLayout 설정
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //검색중일 때 일치하는 목록(tableview) 데이터 바인딩
        festivalSearchViewModel.searchResultsObservable
            .bind(to: tableView.rx.items(cellIdentifier: "FestivalSearchTableViewCell", cellType: FestivalSearchTableViewCell.self)) { [weak self] _, item, cell in
                let attribute = NSMutableAttributedString(string: item.title)
                
                attribute.addAttribute(.foregroundColor, value: UIColor.signatureTintColor(), range: (item.title.lowercased() as NSString).range(of: self?.searchTextForColor.lowercased() ?? ""))
                
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.findingImageView.image = UIImage(systemName: "magnifyingglass")
                cell.titleLabel.attributedText = attribute
            }
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //Cell을 탭했을 때
        tableView.rx.modelSelected(FestivalItem.self).subscribe(onNext: { [weak self] in
            guard let self else { return }
            //내비게이션 컨트롤러의 시작점에 따라 달라짐
            if self.navigationController?.viewControllers.first is FestivalListViewController {
                let festivalSearchResultViewController = FestivalSearchResultViewController(searchText: $0.title)
                
                self.navigationController?.pushViewController(festivalSearchResultViewController, animated: true)
            } else if self.navigationController?.viewControllers.first is CommunityWritingViewController {
                if let viewController = self.navigationController?.viewControllers.first as? CommunityWritingViewController {
                    viewController.festivalTitleReceived?($0.title)
                    viewController.festivalIdReceived?($0.contentid)
                    self.navigationController?.popViewController(animated: true)
                }
            } else if self.navigationController?.viewControllers.first is CommunityViewController {
                let communitySearchResultViewController = CommunitySearchResultViewController(searchText: $0.title)
                
                self.navigationController?.pushViewController(communitySearchResultViewController, animated: true)
            }
        })
        .disposed(by: disposeBag)
    }
    
    ///현재 내비게이션 컨트롤러를 pop
    @objc func dismissSelf() {
        navigationController?.popViewController(animated: true)
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

extension FestivalSearchViewController: UISearchBarDelegate {
    //searchBar에 텍스트를 지속적으로 반영
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        searchTextForColor = searchText
        festivalSearchViewModel.setSearchText(text: searchText)
    }
    
    //검색을 눌렀을 때 검색결과 뷰로 이동
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if navigationController?.viewControllers.first is FestivalListViewController {
            let festivalSearchResultViewController = FestivalSearchResultViewController(searchText: searchBar.searchTextField.text ?? "")
            navigationController?.pushViewController(festivalSearchResultViewController, animated: true)
        }
    }
}
