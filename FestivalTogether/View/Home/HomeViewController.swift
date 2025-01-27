//
//  HomeViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 9/23/24.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher
import Lottie

///'홈'탭 뷰
class HomeViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let homeViewModel = HomeViewModel()
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let appearance = UINavigationBarAppearance()
    private let festiMeetLogoImageView = UIImageView()
    
    private let posterContainerView = UIView()
    private let posterTitle = UILabel()
    private var moreFestivalButtonConfig = UIButton.Configuration.plain()
    private var moreFestivalAttributedString = AttributedString("더 보기")
    private let moreFestivalButton = UIButton()
    private var posterPageControl = UIPageControl()
    private var posterImageScroll = UIScrollView()
    private var timer: Timer?
    
    private let communityContainerView = UIView()
    private let communityTitle = UILabel()
    private let communityTableView = UITableView()
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setBaseView()
        setMainPoster()
        setCommunity()
        bindData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        
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
        //페스티밋 로고
        festiMeetLogoImageView.image = UIImage(resource: .festiMeetLogo).withRenderingMode(.alwaysOriginal).resized(to: CGSize(width: 96.0, height: 20.0))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: festiMeetLogoImageView)
        
        navigationController?.navigationBar.tintColor = .signatureTintColor()
        
        //뒤로가기 제스쳐 활성화를 위한 델리게이트 연결
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.view.backgroundColor = .secondarySystemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        self.view.addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    }
    
    //MARK: setMainPoster()
    ///축제 포스터 관련 뷰
    func setMainPoster() {
        //'축제정보' 레이블 관련
        posterTitle.text = "축제정보"
        posterTitle.font = .mainFontExtraBold(size: 20)
        posterTitle.translatesAutoresizingMaskIntoConstraints = false
        
        //더보기 버튼 관련
        moreFestivalAttributedString.font = .mainFontBold(size: 12)
        moreFestivalButtonConfig.image = UIImage(systemName: "chevron.forward")
        moreFestivalButtonConfig.imagePlacement = .trailing
        moreFestivalButtonConfig.imagePadding = 4.0
        moreFestivalButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .mainFontBold(size: 8.0))
        moreFestivalButtonConfig.baseForegroundColor = .black
        moreFestivalButtonConfig.attributedTitle = moreFestivalAttributedString
        moreFestivalButton.configuration = moreFestivalButtonConfig
        moreFestivalButton.addAction(UIAction { [weak self] _ in
            self?.tabBarController?.selectedIndex = 1
        }, for: .touchUpInside)
        moreFestivalButton.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 포스터 이미지 관련
        posterImageScroll.isPagingEnabled = true
        posterImageScroll.showsHorizontalScrollIndicator = false
        posterImageScroll.delegate = self
        posterImageScroll.translatesAutoresizingMaskIntoConstraints = false
        
        posterPageControl.currentPage = 0
        posterPageControl.numberOfPages = 5
        posterPageControl.isEnabled = false
        posterPageControl.pageIndicatorTintColor = .lightGray
        posterPageControl.currentPageIndicatorTintColor = UIColor.signatureTintColor()
        posterPageControl.translatesAutoresizingMaskIntoConstraints = false
        
        posterContainerView.addSubview(posterTitle)
        posterContainerView.addSubview(moreFestivalButton)
        posterContainerView.addSubview(posterImageScroll)
        posterContainerView.addSubview(posterPageControl)
        stackView.addArrangedSubview(posterContainerView)
        
        //AutoLayout 관련
        posterTitle.leadingAnchor.constraint(equalTo: posterContainerView.leadingAnchor, constant: 24.0).isActive = true
        posterTitle.topAnchor.constraint(equalTo: posterContainerView.topAnchor, constant: 24.0).isActive = true
        posterTitle.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        moreFestivalButton.centerYAnchor.constraint(equalTo: posterTitle.centerYAnchor).isActive = true
        moreFestivalButton.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        posterImageScroll.leadingAnchor.constraint(equalTo: posterContainerView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        posterImageScroll.trailingAnchor.constraint(equalTo: posterContainerView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        posterImageScroll.topAnchor.constraint(equalTo: posterTitle.bottomAnchor, constant: 8.0).isActive = true
        posterImageScroll.heightAnchor.constraint(equalToConstant: self.view.bounds.width - 32.0).isActive = true
        
        posterPageControl.centerXAnchor.constraint(equalTo: posterContainerView.centerXAnchor).isActive = true
        posterPageControl.topAnchor.constraint(equalTo: posterImageScroll.bottomAnchor).isActive = true
        posterPageControl.bottomAnchor.constraint(equalTo: posterContainerView.bottomAnchor).isActive = true
        posterPageControl.leadingAnchor.constraint(equalTo: posterContainerView.leadingAnchor).isActive = true
        posterPageControl.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor).isActive = true
    }
    
    //MARK: setCommunity()
    ///커뮤니티 미리보기 관련
    func setCommunity() {
        //'같이가요' 레이블 관련
        communityTitle.text = "같이가요"
        communityTitle.font = .mainFontExtraBold(size: 20)
        communityTitle.translatesAutoresizingMaskIntoConstraints = false
        
        //TableView 관련
        communityTableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "MainCommunityTableViewCell")
        communityTableView.isScrollEnabled = false
        communityTableView.separatorStyle = .none
        communityTableView.layer.cornerRadius = 12.0
        communityTableView.layer.borderColor = UIColor.systemGray5.cgColor
        communityTableView.layer.borderWidth = 0.5
        communityTableView.clipsToBounds = true
        communityTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedTableView)))
        communityTableView.translatesAutoresizingMaskIntoConstraints = false
        
        //게시글이 없을 때의 레이블
        emptyLabel.text = "등록된 글이 없습니다."
        emptyLabel.font = .mainFontRegular(size: 15.0)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        communityContainerView.addSubview(communityTitle)
        communityContainerView.addSubview(communityTableView)
        communityContainerView.addSubview(emptyLabel)
        stackView.addArrangedSubview(communityContainerView)
        
        //AutoLayout 관련
        communityTitle.topAnchor.constraint(equalTo: communityContainerView.topAnchor, constant: 24.0).isActive = true
        communityTitle.leadingAnchor.constraint(equalTo: communityContainerView.leadingAnchor, constant: 24.0).isActive = true
        communityTitle.trailingAnchor.constraint(equalTo: communityContainerView.trailingAnchor, constant: -24.0).isActive = true
        
        communityTableView.leadingAnchor.constraint(equalTo: communityContainerView.leadingAnchor, constant: 16.0).isActive = true
        communityTableView.topAnchor.constraint(equalTo: communityTitle.bottomAnchor, constant: 8.0).isActive = true
        communityTableView.trailingAnchor.constraint(equalTo: communityContainerView.trailingAnchor, constant: -16.0).isActive = true
        communityTableView.bottomAnchor.constraint(equalTo: communityContainerView.bottomAnchor, constant: -24.0).isActive = true
        communityTableView.heightAnchor.constraint(equalToConstant: 318.0).isActive = true
        
        emptyLabel.centerXAnchor.constraint(equalTo: communityTableView.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: communityTableView.centerYAnchor).isActive = true
    }
    
    //MARK: bindData()
    ///Data와 바인딩
    func bindData() {
        //축제 데이터 바인딩
        homeViewModel.festivalsObservable
            .bind { [weak self] in
                guard let self else { return }
                //각 축제 이미지와 간단한 정보 관련
                for (index, item) in $0.enumerated() {
                    let imageView = UIImageView()
                    
                    let infoContainerView = UIView()
                    let infoTitle = UILabel()
                    let infoDate = UILabel()
                    let infoLocation = UILabel()
                    
                    //축제 이미지 관련
                    if let url = URL(string: item.firstimage) {
                        imageView.kf.setImage(with: url)
                    } else {
                        imageView.image = UIImage(resource: .festiMeetAppIcon)
                        imageView.tintColor = .signatureTintColor()
                    }
                    imageView.clipsToBounds = true
                    imageView.layer.cornerRadius = 12.0
                    imageView.layer.borderColor = UIColor.systemGray5.cgColor
                    imageView.layer.borderWidth = 0.5
                    imageView.accessibilityIdentifier = item.contentid
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedImageView(_:))))
                    imageView.isUserInteractionEnabled = true
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    
                    //간단한 정보 관련
                    infoContainerView.backgroundColor = .white
                    infoContainerView.layer.opacity = 0.9
                    infoContainerView.translatesAutoresizingMaskIntoConstraints = false
                    
                    infoTitle.text = item.title
                    infoTitle.font = .mainFontBold(size: 15)
                    infoTitle.textAlignment = .center
                    infoTitle.numberOfLines = 0
                    infoTitle.translatesAutoresizingMaskIntoConstraints = false
                    
                    infoDate.text = self.homeViewModel.posterDateConvert(startDateString: item.eventstartdate, endDateString: item.eventenddate)
                    infoDate.font = .mainFontRegular(size: 10)
                    infoDate.textAlignment = .center
                    infoDate.translatesAutoresizingMaskIntoConstraints = false
                    
                    infoLocation.text = self.homeViewModel.posterLocationConvert(location: item.addr1)
                    infoLocation.font = .mainFontBold(size: 12)
                    infoLocation.textAlignment = .center
                    infoLocation.translatesAutoresizingMaskIntoConstraints = false
                    
                    infoContainerView.addSubview(infoTitle)
                    infoContainerView.addSubview(infoDate)
                    infoContainerView.addSubview(infoLocation)
                    imageView.addSubview(infoContainerView)
                    self.posterImageScroll.addSubview(imageView)
                    
                    //AutoLayout 관련
                    imageView.leadingAnchor.constraint(equalTo: self.posterImageScroll.leadingAnchor, constant: CGFloat(index) * self.view.bounds.width + 16.0).isActive = true
                    imageView.topAnchor.constraint(equalTo: self.posterImageScroll.topAnchor).isActive = true
                    imageView.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 32.0).isActive = true
                    imageView.heightAnchor.constraint(equalToConstant: self.view.bounds.width - 32.0).isActive = true
                    
                    infoContainerView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
                    infoContainerView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
                    infoContainerView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
                    infoContainerView.topAnchor.constraint(equalTo: infoTitle.topAnchor, constant: -8.0).isActive = true
                    
                    infoTitle.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16.0).isActive = true
                    infoTitle.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16.0).isActive = true
                    infoTitle.bottomAnchor.constraint(equalTo: infoDate.topAnchor).isActive = true
                    
                    infoDate.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16.0).isActive = true
                    infoDate.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16.0).isActive = true
                    infoDate.bottomAnchor.constraint(equalTo: infoLocation.topAnchor).isActive = true
                    
                    infoLocation.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16.0).isActive = true
                    infoLocation.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16.0).isActive = true
                    infoLocation.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor,constant: -8.0).isActive = true
                }
                self.posterImageScroll.contentSize = CGSize(width: self.view.bounds.width * 5.0, height: self.view.bounds.width - 32.0)
            }
            .disposed(by: disposeBag)
        
        //게시글 TableView 바인딩
        homeViewModel.communityObservable
            .bind(to: communityTableView.rx.items(cellIdentifier: "MainCommunityTableViewCell", cellType: CommunityTableViewCell.self)) { [weak self] (row, post, cell) in
                cell.resetCell()
                cell.selectionStyle = .none
                
                cell.festivalLabel.text = post.festivalTitle ?? "-"
                cell.titleLabel.text = post.title
                cell.detailLabel.text = post.detail
                cell.dateLabel.text = self?.homeViewModel.posterCommunityDateConvert(date: post.createdDate)
                cell.nicknameLabel.text = post.nickname
                cell.replyCountLabel.text = "\(post.replyCount)"
            }
            .disposed(by: disposeBag)
        
        //게시글 존재 유무(Bool) 바인딩
        homeViewModel.communityObservable
            .map { !$0.isEmpty }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    //MARK: View 관련 외의 메소드
    ///일정 시간마다 축제 포스터 자동 스크롤을 위한 타이머 시작
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(posterAutoMove), userInfo: nil, repeats: true)
    }
    
    ///다른 뷰로 넘어갈 때 타이머 멈춤
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    ///자동 스크롤
    @objc func posterAutoMove() {
        //마지막 페이지 조건에 따른 스크롤 동작 구분
        if posterPageControl.currentPage < 4 {
            posterPageControl.currentPage += 1
            //페이지 * 너비로 스크롤 위치 조정
            posterImageScroll.scrollRectToVisible(CGRect(x: CGFloat(posterPageControl.currentPage) * posterImageScroll.bounds.width, y: 0, width: posterImageScroll.bounds.width, height: posterImageScroll.bounds.height), animated: true)
        } else {
            posterPageControl.currentPage = 0
            posterImageScroll.scrollRectToVisible(CGRect(x: 0, y: 0, width: posterImageScroll.bounds.width, height: posterImageScroll.bounds.height), animated: true)
        }
    }
    
    ///해당 축제 정보로 이동
    @objc func tappedImageView(_ gesture: UITapGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            let viewController = FestivalDetailViewController(contentId: imageView.accessibilityIdentifier ?? "")
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    ///'게시판'탭으로 이동
    @objc func tappedTableView(_ gesture: UITapGestureRecognizer) {
        tabBarController?.selectedIndex = 2
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

extension HomeViewController: UIGestureRecognizerDelegate {
    //팝 제스쳐 활성화
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension HomeViewController: UIScrollViewDelegate {
    //스크롤이 끝났을 때
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        
        posterPageControl.currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
    }
    
    //사용자의 스크롤 드래그가 끝났을 때
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        stopTimer()
        startTimer()
    }
}

//#Preview {
//    HomeViewController()
//}
