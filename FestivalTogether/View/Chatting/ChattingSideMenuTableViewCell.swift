//
//  ChattingSideMenuTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 11/16/24.
//

import UIKit

class ChattingSideMenuTableViewCell: UITableViewCell {
    let profileImageView = UIImageView()
    let nicknameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    func setCellView() {
        //프로필 이미지
        profileImageView.image = UIImage(resource: .person).withTintColor(.white)
        profileImageView.backgroundColor = .lightGray
        profileImageView.layer.cornerRadius = 20.0
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor.systemGray5.cgColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //닉네임 레이블
        nicknameLabel.font = .mainFontRegular(size: 12.0)
        nicknameLabel.textColor = .black
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        
        //AutoLayout 설정
        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16.0).isActive = true
        nicknameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
    }
    
    func resetCell() {
        profileImageView.image = UIImage(resource: .person).withTintColor(.white)
        nicknameLabel.text = nil
    }
}
