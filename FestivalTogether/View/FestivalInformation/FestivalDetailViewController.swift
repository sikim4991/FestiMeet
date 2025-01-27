//
//  FestivalDetailViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 9/30/24.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import NMapsMap

class FestivalDetailViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var contentId: String
    lazy var festivalDetailViewModel = FestivalDetailViewModel(contentId: contentId)
    
    private let safeAreaView = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let appearance: UINavigationBarAppearance = UINavigationBarAppearance()
    private var navigationFlag = false
    
    private let summaryContainerView = UIView()
    private let imagePageView = {   //상단 축제 이미지 컬렉션뷰
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        collectionViewLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.666)
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        
        let imageView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        imageView.isScrollEnabled = true
        imageView.showsHorizontalScrollIndicator = false
        imageView.showsVerticalScrollIndicator = true
        imageView.clipsToBounds = true
        imageView.register(FestivalDetailImageCollectionViewCell.self, forCellWithReuseIdentifier: "FestivalDetailImageCollectionViewCell")
        imageView.isPagingEnabled = true
        imageView.decelerationRate = .fast
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    private let titleTopDivider = UIView()
    private let festivalTitle = UILabel()
    private let titleBottomDivider = UIView()
    private let dateLabel = UILabel()
    private let festivalDate = UILabel()
    private let timeLabel = UILabel()
    private let festivalTime = UILabel()
    private let addressLabel = UILabel()
    private let festivalAddress = UILabel()
    private let feeLabel = UILabel()
    private let festivalFee = UILabel()
    private let telLabel = UILabel()
    private let festivalTel = UILabel()
    private let festivalTelName = UILabel()
    private let summaryContainerBottomDivider = UIView()
    private var timer: Timer?
    private var currentPage = 0
    
    private let introContainerView = UIView()
    private let introLabel = UILabel()
    private var festivalIntro = UILabel()
    private let introContainerBottomDivider = UIView()
    
    private let mapContainerView = UIView()
    private let mapLabel = UILabel()
    private let mapView = NMFMapView()
    private let marker = NMFMarker()
    private var cameraUpdate = NMFCameraUpdate()
    private let mapContainerBottomDivider = UIView()
    
    private let blankView = UIView()
    
    private var imageViewHeightConstraint: NSLayoutConstraint!
    private var imageViewTopConstraint: NSLayoutConstraint!
    
    init(contentId: String) {
        self.contentId = contentId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setBaseView()
        setSummaryView()
        setInfoView()
        setMapView()
        setBlankView()
        bindData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        
        //내비게이션바 설정
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .secondarySystemBackground
        
        //내비게이션 아이템 설정
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(resource: .chevronLeft), target: self, action: #selector (dismissSelf))
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        //스크롤뷰 설정
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        //스택뷰 설정
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        //AutoLayout 설정
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    //MARK: setSummaryView()
    ///축제정보 요약 뷰
    func setSummaryView() {
        summaryContainerView.backgroundColor = .white
        
        //축제 이미지 컬렉션
        imagePageView.delegate = self
        imagePageView.backgroundColor = .black
        
        titleTopDivider.backgroundColor = .systemGray5
        titleTopDivider.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 이름
        festivalTitle.font = .mainFontBold(size: 20.0)
        festivalTitle.numberOfLines = 0
        festivalTitle.textAlignment = .center
        festivalTitle.translatesAutoresizingMaskIntoConstraints = false
        
        titleBottomDivider.backgroundColor = .systemGray5
        titleBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 진행 날짜
        dateLabel.text = "진행기간"
        dateLabel.font = .mainFontRegular(size: 12.0)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalDate.font = .mainFontRegular(size: 12.0)
        festivalDate.numberOfLines = 0
        festivalDate.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 진행 시간
        timeLabel.text = "진행시간"
        timeLabel.font = .mainFontRegular(size: 12.0)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalTime.font = .mainFontRegular(size: 12.0)
        festivalTime.numberOfLines = 0
        festivalTime.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 장소
        addressLabel.text = "주소"
        addressLabel.font = .mainFontRegular(size: 12.0)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalAddress.font = .mainFontRegular(size: 12.0)
        festivalAddress.numberOfLines = 0
        festivalAddress.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 비용
        feeLabel.text = "입장비(참가비)"
        feeLabel.font = .mainFontRegular(size: 12.0)
        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalFee.font = .mainFontRegular(size: 12.0)
        festivalFee.numberOfLines = 0
        festivalFee.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 문의처
        telLabel.text = "문의"
        telLabel.font = .mainFontRegular(size: 12.0)
        telLabel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalTel.font = .mainFontRegular(size: 12.0)
        festivalTel.numberOfLines = 0
        festivalTel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalTelName.font = .mainFontRegular(size: 12.0)
        festivalTelName.numberOfLines = 0
        festivalTelName.translatesAutoresizingMaskIntoConstraints = false
        
        summaryContainerBottomDivider.backgroundColor = .systemGray5
        summaryContainerBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        summaryContainerView.addSubview(imagePageView)
        summaryContainerView.addSubview(titleTopDivider)
        summaryContainerView.addSubview(festivalTitle)
        summaryContainerView.addSubview(titleBottomDivider)
        summaryContainerView.addSubview(dateLabel)
        summaryContainerView.addSubview(festivalDate)
        summaryContainerView.addSubview(timeLabel)
        summaryContainerView.addSubview(festivalTime)
        summaryContainerView.addSubview(addressLabel)
        summaryContainerView.addSubview(festivalAddress)
        summaryContainerView.addSubview(feeLabel)
        summaryContainerView.addSubview(festivalFee)
        summaryContainerView.addSubview(telLabel)
        summaryContainerView.addSubview(festivalTel)
        summaryContainerView.addSubview(festivalTelName)
        summaryContainerView.addSubview(summaryContainerBottomDivider)
        stackView.addArrangedSubview(summaryContainerView)
        
        //AutoLayout 설정
        imageViewHeightConstraint = imagePageView.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.666)
        imageViewTopConstraint = imagePageView.topAnchor.constraint(equalTo: summaryContainerView.topAnchor)
        
        imagePageView.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor).isActive = true
        imageViewTopConstraint.isActive = true
        imagePageView.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor).isActive = true
        imageViewHeightConstraint.isActive = true
        
        titleTopDivider.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor).isActive = true
        titleTopDivider.topAnchor.constraint(equalTo: imagePageView.bottomAnchor).isActive = true
        titleTopDivider.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor).isActive = true
        titleTopDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        festivalTitle.topAnchor.constraint(equalTo: titleTopDivider.bottomAnchor, constant: 16.0).isActive = true
        festivalTitle.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 24.0).isActive = true
        festivalTitle.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        titleBottomDivider.topAnchor.constraint(equalTo: festivalTitle.bottomAnchor, constant: 16.0).isActive = true
        titleBottomDivider.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor).isActive = true
        titleBottomDivider.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor).isActive = true
        titleBottomDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        dateLabel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 24.0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: titleBottomDivider.bottomAnchor, constant: 16.0).isActive = true
        
        festivalDate.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 140.0).isActive = true
        festivalDate.topAnchor.constraint(equalTo: titleBottomDivider.bottomAnchor, constant: 16.0).isActive = true
        festivalDate.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        timeLabel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 24.0).isActive = true
        timeLabel.topAnchor.constraint(equalTo: festivalDate.bottomAnchor, constant: 16.0).isActive = true
        
        festivalTime.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 140.0).isActive = true
        festivalTime.topAnchor.constraint(equalTo: festivalDate.bottomAnchor, constant: 16.0).isActive = true
        festivalTime.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        addressLabel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 24.0).isActive = true
        addressLabel.topAnchor.constraint(equalTo: festivalTime.bottomAnchor, constant: 16.0).isActive = true
        
        festivalAddress.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 140.0).isActive = true
        festivalAddress.topAnchor.constraint(equalTo: festivalTime.bottomAnchor, constant: 16.0).isActive = true
        festivalAddress.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        feeLabel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 24.0).isActive = true
        feeLabel.topAnchor.constraint(equalTo: festivalAddress.bottomAnchor, constant: 16.0).isActive = true
        
        festivalFee.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 140.0).isActive = true
        festivalFee.topAnchor.constraint(equalTo: festivalAddress.bottomAnchor, constant: 16.0).isActive = true
        festivalFee.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        telLabel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 24.0).isActive = true
        telLabel.topAnchor.constraint(equalTo: festivalFee.bottomAnchor, constant: 16.0).isActive = true
        
        festivalTel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 140.0).isActive = true
        festivalTel.topAnchor.constraint(equalTo: festivalFee.bottomAnchor, constant: 16.0).isActive = true
        festivalTel.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        festivalTelName.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 140.0).isActive = true
        festivalTelName.topAnchor.constraint(equalTo: festivalTel.bottomAnchor).isActive = true
        festivalTelName.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        summaryContainerBottomDivider.topAnchor.constraint(equalTo: festivalTelName.bottomAnchor, constant: 16.0).isActive = true
        summaryContainerBottomDivider.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor).isActive = true
        summaryContainerBottomDivider.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor).isActive = true
        summaryContainerBottomDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        summaryContainerBottomDivider.bottomAnchor.constraint(equalTo: summaryContainerView.bottomAnchor).isActive = true
    }
    
    //MARK: setInfoView()
    ///축제 정보 뷰
    func setInfoView() {
        introContainerView.backgroundColor = .white
        
        //축제 소개
        introLabel.text = "소개"
        introLabel.font = .mainFontBold(size: 15.0)
        introLabel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalIntro.font = .mainFontRegular(size: 12.0)
        festivalIntro.numberOfLines = 0
        festivalIntro.translatesAutoresizingMaskIntoConstraints = false
        
        introContainerBottomDivider.backgroundColor = .systemGray5
        introContainerBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        introContainerView.addSubview(introLabel)
        introContainerView.addSubview(festivalIntro)
        introContainerView.addSubview(introContainerBottomDivider)
        stackView.addArrangedSubview(introContainerView)
        
        //AutoLayout 설정
        introLabel.leadingAnchor.constraint(equalTo: introContainerView.leadingAnchor, constant: 24.0).isActive = true
        introLabel.topAnchor.constraint(equalTo: introContainerView.topAnchor, constant: 16.0).isActive = true
        introLabel.trailingAnchor.constraint(equalTo: introContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        festivalIntro.leadingAnchor.constraint(equalTo: introContainerView.leadingAnchor, constant: 24.0).isActive = true
        festivalIntro.topAnchor.constraint(equalTo: introLabel.bottomAnchor, constant: 16.0).isActive = true
        festivalIntro.trailingAnchor.constraint(equalTo: introContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        introContainerBottomDivider.leadingAnchor.constraint(equalTo: introContainerView.leadingAnchor).isActive = true
        introContainerBottomDivider.topAnchor.constraint(equalTo: festivalIntro.bottomAnchor, constant: 16.0).isActive = true
        introContainerBottomDivider.trailingAnchor.constraint(equalTo: introContainerView.trailingAnchor).isActive = true
        introContainerBottomDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        introContainerBottomDivider.bottomAnchor.constraint(equalTo: introContainerView.bottomAnchor).isActive = true
    }
    
    //MARK: setMapView()
    ///네이버 지도 뷰
    func setMapView() {
        mapContainerView.backgroundColor = .white
        
        //지도 레이블
        mapLabel.text = "위치"
        mapLabel.font = .mainFontBold(size: 15.0)
        mapLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //네이버 지도
        mapView.zoomLevel = 15.0
        mapView.layer.borderColor = UIColor.systemGray5.cgColor
        mapView.layer.borderWidth = 0.5
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapContainerBottomDivider.backgroundColor = .systemGray5
        mapContainerBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        mapContainerView.addSubview(mapLabel)
        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(mapContainerBottomDivider)
        stackView.addArrangedSubview(mapContainerView)
        
        //AutoLayout 설정
        mapLabel.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor, constant: 24.0).isActive = true
        mapLabel.topAnchor.constraint(equalTo: mapContainerView.topAnchor, constant: 16.0).isActive = true
        mapLabel.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        mapView.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor, constant: 24.0).isActive = true
        mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 16.0).isActive = true
        mapView.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor, constant: -24.0).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: view.bounds.width - 48.0).isActive = true
        
        mapContainerBottomDivider.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor).isActive = true
        mapContainerBottomDivider.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16.0).isActive = true
        mapContainerBottomDivider.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor).isActive = true
        mapContainerBottomDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        mapContainerBottomDivider.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor).isActive = true
    }
    
    //MARK: setBlankView()
    ///빈공간 뷰
    func setBlankView() {
        blankView.backgroundColor = .secondarySystemBackground
        blankView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(blankView)
        
        blankView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        blankView.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
    }
    
    //MARK: bindData()
    ///데이터 바인딩
    func bindData() {
        //MARK: OUTPUT
        //축제 이름 데이터 바인딩
        festivalDetailViewModel.titleObservable
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        //축제 이미지 데이터 바인딩
        festivalDetailViewModel.imageURLStringsObservable
            .bind(to: imagePageView.rx.items(cellIdentifier: "FestivalDetailImageCollectionViewCell", cellType: FestivalDetailImageCollectionViewCell.self)) { _, item, cell in
                cell.resetCell()
                
                if let url = URL(string: item) {
                    cell.imageView.kf.setImage(with: url)
                }
                if cell.imageView.image == nil {
                    cell.imageView.image = UIImage(resource: .festiMeetAppIcon)
                    cell.imageView.tintColor = .signatureTintColor()
                }
            }
            .disposed(by: disposeBag)
        
        //축제 이름 데이터 바인딩
        festivalDetailViewModel.titleObservable
            .bind(to: festivalTitle.rx.text)
            .disposed(by: disposeBag)
        
        //축제 날짜 데이터 바인딩
        festivalDetailViewModel.dateStringObservable
            .bind(to: festivalDate.rx.text)
            .disposed(by: disposeBag)
        
        //축제 시간 데이터 바인딩
        festivalDetailViewModel.timeStringObservable
            .bind(to: festivalTime.rx.text)
            .disposed(by: disposeBag)
        
        //축제 장소 데이터 바인딩
        festivalDetailViewModel.addressObservable
            .bind(to: festivalAddress.rx.text)
            .disposed(by: disposeBag)
        
        //축제 비용 데이터 바인딩
        festivalDetailViewModel.feeObservable
            .bind(to: festivalFee.rx.text)
            .disposed(by: disposeBag)
        
        //축제 문의처 번호 데이터 바인딩
        festivalDetailViewModel.telObservable
            .bind(to: festivalTel.rx.text)
            .disposed(by: disposeBag)
        
        //축제 문의처 데이터 바인딩
        festivalDetailViewModel.telNameObservable
            .bind(to: festivalTelName.rx.text)
            .disposed(by: disposeBag)
        
        //축제 소개 데이터 바인딩
        festivalDetailViewModel.introObservable
            .bind { [weak self] text in
                self?.festivalIntro.text = text
                self?.festivalIntro.setLineSpacing(lineSpacing: 4.0)
            }
            .disposed(by: disposeBag)
        
        //축제 지도 좌표 데이터 바인딩
        festivalDetailViewModel.mapxyObservable
            .bind { [weak self] in
                guard let self else { return }
                marker.position = $0
                self.cameraUpdate = NMFCameraUpdate(scrollTo: $0)
                self.mapView.moveCamera(self.cameraUpdate)
                marker.mapView = mapView
            }
            .disposed(by: disposeBag)
        
        //MARK: INPUT
        //이미지 선택 시 전체화면으로 표시
        imagePageView.rx.itemSelected.subscribe(onNext: { [weak self] in
            let imageDetailViewController = ImageDetailViewController(indexPath: $0)
            guard let self else { return }
            
            imageDetailViewController.bindData(urlStringsOb: self.festivalDetailViewModel.imageURLStringsObservable)
            imageDetailViewController.modalPresentationStyle = .fullScreen
            
            self.present(imageDetailViewController, animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
    }
    
    //MARK: 뷰 관련 이외 메소드
    ///이미지 자동 스크롤을 위한 타이머 시작
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(imageAutoMove), userInfo: nil, repeats: true)
    }
    
    ///이미지 자동 스크롤 타이머 멈춤
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    ///이미지 자동 스크롤
    @objc func imageAutoMove() {
        if currentPage == imagePageView.numberOfItems(inSection: 0) - 1 {
            currentPage = 0
        } else {
            currentPage += 1
        }
        imagePageView.scrollToItem(at: NSIndexPath(item: currentPage, section: 0) as IndexPath, at: .right, animated: true)
    }
    
    ///내비게이션 컨트롤러 Pop
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

extension FestivalDetailViewController: UIScrollViewDelegate {
    //스크롤이 끝났을 때
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //오프셋 y 위치에 따라 내비게이션바 관련 색상이 바뀜
        if scrollView.contentOffset.y <= (imageViewHeightConstraint.constant - ((self.navigationController?.navigationBar.bounds.height ?? 0) + 40)) && !navigationFlag {
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            navigationItem.leftBarButtonItem?.tintColor = .white
            navigationFlag = true
        } else if scrollView.contentOffset.y > (imageViewHeightConstraint.constant - ((self.navigationController?.navigationBar.bounds.height ?? 0) + 40)) && navigationFlag {
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            appearance.backgroundColor = .signatureBackgroundColor()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.signatureTintColor(), .font: UIFont.mainFontBold(size: 15.0)]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            navigationItem.leftBarButtonItem?.tintColor = .signatureTintColor()
            navigationFlag = false
        }
    }
}

extension FestivalDetailViewController: UICollectionViewDelegate {
    //스크롤뷰가 완전히 멈췄을 때, 현재 페이지 계산
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    //사용자가 스크롤 드래그를 끝낼 때, 타이머 재시작
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        stopTimer()
        startTimer()
    }
}
