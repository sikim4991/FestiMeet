//
//  PostCollectionReusableView.swift
//  FestivalTogether
//
//  Created by SIKim on 10/19/24.
//

import UIKit

class PostCollectionReusableView: UICollectionReusableView {
    let profileImageView = UIImageView()
    let nicknameLabel = UILabel()
    let createdDateLabel = UILabel()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    var festivalButtonConfig = UIButton.Configuration.plain()
    var festivalAttributedTitle = AttributedString()
    var festivalAttributedSubtitle = AttributedString("살펴보기")
    var festivalButton = UIButton()
    let bottomDivider = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView() {
        self.backgroundColor = .white
        
        //프로필 이미지
        profileImageView.image = UIImage(resource: .person).withTintColor(.white)
        profileImageView.backgroundColor = .lightGray
        profileImageView.layer.cornerRadius = 20.0
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor.systemGray5.cgColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //닉네임
        nicknameLabel.text = "nickname"
        nicknameLabel.font = .mainFontBold(size: 12.0)
        nicknameLabel.textColor = .black
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //게시 날짜
        createdDateLabel.text = "createdDate"
        createdDateLabel.font = .mainFontRegular(size: 12.0)
        createdDateLabel.textColor = .lightGray
        createdDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //게시글 제목
        titleLabel.text = "Title"
        titleLabel.font = .mainFontBold(size: 15.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //게시글 내용
        detailLabel.text = "Detail"
        detailLabel.font = .mainFontRegular(size: 12.0)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        festivalAttributedTitle.font = .mainFontBold(size: 12.0)
        festivalAttributedSubtitle.font = .mainFontRegular(size: 12.0)
        
        //축제 정보 버튼
        festivalButtonConfig.baseForegroundColor = .black
        festivalButtonConfig.image = UIImage(systemName: "chevron.forward")
        festivalButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .mainFontRegular(size: 12.0))
        festivalButtonConfig.imagePlacement = .trailing
        festivalButtonConfig.imagePadding = 16.0
        festivalButtonConfig.background.strokeColor = .systemGray5
        festivalButtonConfig.background.strokeWidth = 1.0
        festivalButtonConfig.attributedTitle = festivalAttributedTitle
        festivalButtonConfig.attributedSubtitle = festivalAttributedSubtitle
        festivalButtonConfig.titleAlignment = .center
        festivalButton.configuration = festivalButtonConfig
        festivalButton.translatesAutoresizingMaskIntoConstraints = false
        
        bottomDivider.backgroundColor = .systemGray5
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(profileImageView)
        self.addSubview(nicknameLabel)
        self.addSubview(createdDateLabel)
        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        self.addSubview(festivalButton)
        self.addSubview(bottomDivider)
        
        //AutoLayout 설정
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8.0).isActive = true
        nicknameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 4.0).isActive = true
        nicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -24.0).isActive = true
        
        createdDateLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8.0).isActive = true
        createdDateLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -4.0).isActive = true
        createdDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -24.0).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16.0).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -24.0).isActive = true
        
        detailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0).isActive = true
        detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -24.0).isActive = true
        
        festivalButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        festivalButton.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 16.0).isActive = true
        festivalButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        
        bottomDivider.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomDivider.topAnchor.constraint(equalTo: festivalButton.bottomAnchor, constant: 16.0).isActive = true
        bottomDivider.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomDivider.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomDivider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
}
