//
//  FestivalListViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 9/27/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

//'축제정보'탭 뷰
class FestivalListViewController: UIViewController {
    private let festivalListViewModel = FestivalListViewModel()
    
    private let appearance = UINavigationBarAppearance()
    
    private let searchBarController = UISearchController()
    private let stackView = UIStackView()
    private let filterContainerView = UIView()
    private let blurredEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private let datePicker = UIDatePicker()
    private var visitDateFilterButton = UIButton()
    private var locationFilterButton = UIButton()
    private var locationMenuItems: [UIAction] = []
    
    private let tableView = UITableView()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setBaseView()
        setFilterView()
        setTableView()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //내비게이션바 설정 관련
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.signatureBackgroundColor()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        self.view.backgroundColor = .secondarySystemBackground
        
        //내비게이션 아이템 설정
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(resource: .search), style: .plain, target: self, action: #selector(pushViewController))
        self.navigationController?.navigationBar.tintColor = .signatureTintColor()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        //AutoLayout 설정
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //MARK: setFilterView()
    ///방문예정일, 지역 필터 버튼 관련 뷰
    func setFilterView() {
        //방문예정일 버튼 관련
        var visitDateFilterButtonConfig = UIButton.Configuration.bordered()
        var visitDateFilterAttributedTitle = AttributedString("방문예정일")
        var visitDateFilterAttributedSubtitle = AttributedString()
        
        //지역 버튼 관련
        var locationFilterButtonConfig = UIButton.Configuration.bordered()
        var locationFilterAttrbutedTitle = AttributedString("지역")
        var locationFilterAttributedSubtitle = AttributedString()
        
        filterContainerView.backgroundColor = .white
        
        //DatePicker 설정
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.layer.cornerRadius = 12.0
        datePicker.backgroundColor = .white
        datePicker.clipsToBounds = true
        datePicker.isHidden = true
        datePicker.addTarget(self, action: #selector(pickDate), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        //DatePicker 배경 블러 관련
        blurredEffectView.isHidden = true
        blurredEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker)))
        blurredEffectView.isUserInteractionEnabled = true
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        //방문예정일 버튼 관련
        visitDateFilterAttributedTitle.font = .mainFontRegular(size: 10.0)
        visitDateFilterAttributedSubtitle.font = .mainFontBold(size: 12.0)
        
        visitDateFilterButtonConfig.attributedTitle = visitDateFilterAttributedTitle
        visitDateFilterButtonConfig.attributedSubtitle = visitDateFilterAttributedSubtitle
        visitDateFilterButtonConfig.titleAlignment = .center
        visitDateFilterButtonConfig.image = UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10.0))
        visitDateFilterButtonConfig.imagePlacement = .trailing
        visitDateFilterButtonConfig.imagePadding = 2.0
        visitDateFilterButtonConfig.cornerStyle = .capsule
        visitDateFilterButtonConfig.baseForegroundColor = .black
        visitDateFilterButtonConfig.background.backgroundColor = .white
        visitDateFilterButtonConfig.background.strokeColor = .systemGray5
        visitDateFilterButtonConfig.background.strokeWidth = 1.0
        visitDateFilterButton = UIButton(configuration: visitDateFilterButtonConfig)
        visitDateFilterButton.translatesAutoresizingMaskIntoConstraints = false
        
        //지역 버튼 관련
        locationFilterAttrbutedTitle.font = .mainFontRegular(size: 10.0)
        locationFilterAttributedSubtitle.font = .mainFontBold(size: 12.0)
        
        locationFilterButtonConfig.attributedTitle = locationFilterAttrbutedTitle
        locationFilterButtonConfig.attributedSubtitle = locationFilterAttributedSubtitle
        locationFilterButtonConfig.titleAlignment = .center
        locationFilterButtonConfig.image = UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10.0))
        locationFilterButtonConfig.imagePlacement = .trailing
        locationFilterButtonConfig.imagePadding = 2.0
        locationFilterButtonConfig.cornerStyle = .capsule
        locationFilterButtonConfig.baseForegroundColor = .black
        locationFilterButtonConfig.background.backgroundColor = .white
        locationFilterButtonConfig.background.strokeColor = .systemGray5
        locationFilterButtonConfig.background.strokeWidth = 1.0
        locationFilterButton = UIButton(configuration: locationFilterButtonConfig)
        locationFilterButton.translatesAutoresizingMaskIntoConstraints = false
        
        locationFilterButton.showsMenuAsPrimaryAction = true
        
        view.addSubview(blurredEffectView)
        view.addSubview(datePicker)
        stackView.addArrangedSubview(filterContainerView)
        filterContainerView.addSubview(visitDateFilterButton)
        filterContainerView.addSubview(locationFilterButton)
        
        //AutoLayout 관련
        blurredEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurredEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurredEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurredEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: 300).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        visitDateFilterButton.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: 16.0).isActive = true
        visitDateFilterButton.topAnchor.constraint(equalTo: filterContainerView.topAnchor, constant: 10.0).isActive = true
        visitDateFilterButton.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor, constant: -10.0).isActive = true
        
        locationFilterButton.leadingAnchor.constraint(equalTo: visitDateFilterButton.trailingAnchor, constant: 10.0).isActive = true
        locationFilterButton.topAnchor.constraint(equalTo: filterContainerView.topAnchor, constant: 10.0).isActive = true
        locationFilterButton.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor, constant: -10.0).isActive = true
    }
    
    //MARK: setTableView()
    ///TableView 관련
    func setTableView() {
        tableView.register(FestivalTableViewCell.self, forCellReuseIdentifier: "FestivalTableViewCell")
        tableView.backgroundColor = .secondarySystemBackground
        
        stackView.addArrangedSubview(tableView)
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //선택한 날짜 데이터 바인딩
        festivalListViewModel.dateForFilterSubject
            .map {
                let dateFormatter = DateFormatter()
                var dateString = ""
                
                dateFormatter.dateFormat = "yyyy년 M월 d일"
                dateFormatter.locale = Locale(identifier: "ko_kr")
                dateFormatter.timeZone = TimeZone(abbreviation: "KST")
                
                dateString = dateFormatter.string(from: $0)
                return dateString
            }
            .bind { [weak self] in
                self?.visitDateFilterButton.configuration?.subtitle = $0
            }
            .disposed(by: disposeBag)
        
        //지역 버튼의 메뉴들과 데이터 바인딩
        festivalListViewModel.allAreaCodeSubject
            .subscribe(onNext: { [weak self] areaCodeItems in
                guard let self else { return }
                areaCodeItems.forEach { item in
                    self.locationMenuItems.append(UIAction(title: item.name) { _ in
                        self.festivalListViewModel.areaCodeForFilterSubject.onNext(item)
                    })
                }
                self.locationFilterButton.menu = UIMenu(children: self.locationMenuItems)
            })
            .disposed(by: disposeBag)
        
        //선택한 지역 데이터 바인딩
        festivalListViewModel.areaCodeForFilterSubject
            .map { $0.name }
            .bind { [weak self] in
                self?.locationFilterButton.configuration?.subtitle = $0
            }
            .disposed(by: disposeBag)
        
        //지역 변경시 페이지 리셋
        festivalListViewModel.areaCodeForFilterSubject
            .subscribe(onNext: { [weak self] _ in
                self?.festivalListViewModel.resetPagination()
            })
            .disposed(by: disposeBag)
        
        //축제 정보 데이터 바인딩
        festivalListViewModel.festivalForPaginationObservable
            .bind(to: tableView.rx.items(cellIdentifier: "FestivalTableViewCell", cellType: FestivalTableViewCell.self)) { [weak self] index, item, cell in
                cell.resetCell()
                cell.selectionStyle = .none
                
                if let url = URL(string: item.firstimage) {
                    cell.mainImageView.kf.setImage(with: url)
                }
                if cell.mainImageView.image == nil {
                    cell.mainImageView.image = UIImage(resource: .festiMeetAppIcon)
                    cell.mainImageView.tintColor = .signatureTintColor()
                }
                cell.titleLabel.text = item.title
                cell.startDateTitle.text = "시작일"
                cell.startDateLabel.text = self?.festivalListViewModel.dateConvert(dateString: item.eventstartdate)
                cell.endDateTitle.text = "종료일"
                cell.endDateLabel.text = self?.festivalListViewModel.dateConvert(dateString: item.eventenddate)
                cell.addressLabel.text = "\(item.addr1) \(item.addr2)"
            }
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //방문예정일 버튼 탭
        visitDateFilterButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.datePicker.isHidden = false
            self?.blurredEffectView.isHidden = false
        })
        .disposed(by: disposeBag)
        
        //TableView Pagination 적용
        tableView.rx.prefetchRows
            .compactMap { $0.last?.row }
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { vc, row in
                return row >= vc.festivalListViewModel.currentItemsCount - 1
            }
            .subscribe(onNext: { vc, row in
                vc.festivalListViewModel.loadForPagination()
            })
            .disposed(by: disposeBag)
        
        //TableView에서 Cell선택, 축제 정보로 이동
        tableView.rx.modelSelected(FestivalItem.self)
            .subscribe(onNext: { [weak self] in
                let festivalDetailViewController = FestivalDetailViewController(contentId: $0.contentid)

                self?.navigationController?.pushViewController(festivalDetailViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: View 관련 이외 메소드
    ///검색 뷰로 이동
    @objc func pushViewController() {
        let viewController = FestivalSearchViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    ///DatePicker에서 날짜 선택
    @objc func pickDate(_ sender: UIDatePicker) {
        festivalListViewModel.resetPagination()
        festivalListViewModel.pickDateForFilter(date: sender.date)
        datePicker.isHidden = true
        blurredEffectView.isHidden = true
    }
    
    ///DatePicker 취소
    @objc func dismissDatePicker() {
        datePicker.isHidden = true
        blurredEffectView.isHidden = true
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

extension FestivalListViewController: UIGestureRecognizerDelegate {
    //팝 제스쳐 활성화
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
