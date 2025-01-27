//
//  CommunitySearchViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/22/24.
//

import UIKit
import RxSwift
import RxCocoa

class CommunitySearchViewController: UIViewController {
    private let appearance = UINavigationBarAppearance()
    private let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 0))
    
    private var mainImageView = UIImageView()
    private var mainLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setMainView()
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
    
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        //searchBar 설정
        searchBar.tintColor = .signatureTintColor()
        searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "행사 이름", attributes: [.font: UIFont.mainFontRegular(size: 12.0)])
        
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        //내비게이션 아이템 설정
        navigationController?.navigationBar.tintColor = .signatureTintColor()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.titleView = searchBar
    }
    
    ///메인 뷰
    func setMainView() {
        //메인화면 돋보기 이미지
        mainImageView.image = UIImage(systemName: "magnifyingglass")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 50.0))
        mainImageView.tintColor = .lightGray
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //메인화면 레이블
        mainLabel.text = "검색어를 입력하세요."
        mainLabel.textColor = .lightGray
        mainLabel.font = .mainFontBold(size: 15.0)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainImageView)
        view.addSubview(mainLabel)
        
        mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75.0).isActive = true
        mainImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        mainLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 8.0).isActive = true
        mainLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
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

extension CommunitySearchViewController: UISearchBarDelegate {
    //검색 시, 검색결과 뷰로 이동
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let viewController = CommunitySearchResultViewController(searchText: searchBar.searchTextField.text ?? "")
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
