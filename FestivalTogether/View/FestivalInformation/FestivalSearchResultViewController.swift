//
//  FestivalSearchResultViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/3/24.
//

import UIKit
import RxSwift
import RxCocoa

///축제 검색결과 뷰
class FestivalSearchResultViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private lazy var festivalSearchResultViewModel = FestivalSearchResultViewModel(searchText: searchText)
    
    private let appearance = UINavigationBarAppearance()
    var searchText: String
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setTableView()
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
        
        //내비게이션 아이템 설정
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.title = "\"\(searchText)\""
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(FestivalTableViewCell.self, forCellReuseIdentifier: "FestivalSearchResultTableViewCell")
        tableView.backgroundColor = .secondarySystemBackground
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
        //TableView 검색결과에 대한 축제 데이터 바인딩
        festivalSearchResultViewModel.filteredFestivalsObservable
            .bind(to: tableView.rx.items(cellIdentifier: "FestivalSearchResultTableViewCell", cellType: FestivalTableViewCell.self)) { [weak self] index, item, cell in
                let attribute = NSMutableAttributedString(string: item.title)
                
                attribute.addAttribute(.foregroundColor, value: UIColor.signatureTintColor(), range: (item.title.lowercased() as NSString).range(of: self?.searchText.lowercased() ?? ""))
                
                cell.resetCell()
                cell.selectionStyle = .none
                
                if let url = URL(string: item.firstimage) {
                    cell.mainImageView.kf.setImage(with: url)
                }
                if cell.mainImageView.image == nil {
                    cell.mainImageView.image = UIImage(resource: .festiMeetAppIcon)
                    cell.mainImageView.tintColor = .signatureTintColor()
                }
                cell.titleLabel.attributedText = attribute
                cell.startDateTitle.text = "시작일"
                cell.startDateLabel.text = self?.festivalSearchResultViewModel.dateConvert(dateString: item.eventstartdate)
                cell.endDateTitle.text = "종료일"
                cell.endDateLabel.text = self?.festivalSearchResultViewModel.dateConvert(dateString: item.eventenddate)
                cell.addressLabel.text = "\(item.addr1) \(item.addr2)"
            }
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //Cell을 탭했을 때, 축제 정보를 보여주는 뷰로 이동
        tableView.rx.modelSelected(FestivalItem.self)
            .subscribe(onNext: { [weak self] in
                let festivalDetailViewController = FestivalDetailViewController(contentId: $0.contentid)
                
                self?.navigationController?.pushViewController(festivalDetailViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //내비게이션 컨트롤러 Pop
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
