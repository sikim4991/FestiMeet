//
//  ImageDetailViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/4/24.
//

import UIKit
import RxSwift
import RxCocoa

///축제 이미지 상세 뷰
class ImageDetailViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let closeButton = UIButton()
    private let countLabel = UILabel()
    private var imageCount = 0
    private let imageView = {   //축제 이미지 컬렉션 뷰
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        //컬렉션뷰 레이아웃 관련
        collectionViewLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        
        //이미지뷰 관련
        let imageView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        imageView.isScrollEnabled = true
        imageView.showsHorizontalScrollIndicator = false
        imageView.showsVerticalScrollIndicator = true
        imageView.clipsToBounds = true
        imageView.register(ImageDetailCollectionViewCell.self, forCellWithReuseIdentifier: "ImageDetailCollectionViewCell")
        imageView.isPagingEnabled = true
        imageView.decelerationRate = .fast
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    var indexPath: IndexPath
    
    
    init(indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        setImageView()
        setCloseButton()
        setCountLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    //MARK: setBaseView()
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .black
    }
    
    //MARK: setImageView()
    ///이미지뷰 관련
    func setImageView() {
        imageView.delegate = self
        
        view.addSubview(imageView)
        
        //AutoLayout 설정
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //MARK: setCloseButton()
    ///닫기 버튼 관련
    func setCloseButton() {
        var buttonConfig = UIButton.Configuration.plain()
        
        buttonConfig.baseForegroundColor = .lightGray
        buttonConfig.image = UIImage(systemName: "xmark.circle.fill")
        
        closeButton.configuration = buttonConfig
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(closeButton)
        
        //AutoLayout 설정
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24.0).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        closeButton.centerXAnchor.constraint(greaterThanOrEqualTo: view.centerXAnchor).isActive = true
    }
    
    //MARK: setCountLabel()
    ///이미지 페이지 관련
    func setCountLabel() {
        countLabel.text = "\(indexPath.row + 1) / \(imageCount)"
        countLabel.textColor = .white
        countLabel.font = .mainFontRegular(size: 12.0)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(countLabel)
        
        //AutoLayout 설정
        countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        countLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //MARK: bindData(urlStringsOb: )
    ///데이터 바인딩
    func bindData(urlStringsOb: Observable<[String]>) {
        //이미지 데이터 바인딩
        urlStringsOb.bind(to: imageView.rx.items(cellIdentifier: "ImageDetailCollectionViewCell", cellType: ImageDetailCollectionViewCell.self)) { _, item, cell in
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
        
        //이미지 페이지수 바인딩
        urlStringsOb.subscribe(onNext: { [weak self] in
            self?.imageCount = $0.count
        })
        .disposed(by: disposeBag)
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

extension ImageDetailViewController: UICollectionViewDelegate {
    //스크롤뷰가 완전히 멈췄을 때, 현재 페이지 계산
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        countLabel.text = "\(currentPage + 1) / \(imageCount)"
    }
}
