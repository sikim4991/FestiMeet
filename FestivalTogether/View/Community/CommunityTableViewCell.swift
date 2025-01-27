//
//  CommunityTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 10/7/24.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {
    let festivalLabel = UILabel()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    let dateLabel = UILabel()
    let divider = UIView()
    let nicknameLabel = UILabel()
    let replyImageView = UIImageView()
    let replyCountLabel = UILabel()
    let bottomDivider = UIView()

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
        //축제 이름
        festivalLabel.font = .mainFontBold(size: 10.0)
        festivalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //게시글 제목
        titleLabel.font = .mainFontBold(size: 15.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //게시글 내용
        detailLabel.font = .mainFontRegular(size: 12.0)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //게시 날짜
        dateLabel.font = .mainFontRegular(size: 12.0)
        dateLabel.textColor = .lightGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        divider.backgroundColor = .lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        //닉네임
        nicknameLabel.font = .mainFontRegular(size: 12.0)
        nicknameLabel.textColor = .lightGray
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //댓글 말풍선 이미지
        replyImageView.image = UIImage(systemName: "bubble")
        replyImageView.tintColor = .black
        replyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //댓글 수
        replyCountLabel.font = .mainFontRegular(size: 12.0)
        replyCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomDivider.backgroundColor = .systemGray5
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(festivalLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(divider)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(replyImageView)
        contentView.addSubview(replyCountLabel)
        contentView.addSubview(bottomDivider)
        
        //AutoLayout 설정
        festivalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        festivalLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        festivalLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: festivalLabel.bottomAnchor, constant: 8.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        
        detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0).isActive = true
        detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 8.0).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor, constant: -16.0).isActive = true
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        divider.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 4.0).isActive = true
        divider.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 10.0).isActive = true
        divider.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor, constant: -18.0).isActive = true
        divider.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        nicknameLabel.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 4.0).isActive = true
        nicknameLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 8.0).isActive = true
        nicknameLabel.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor, constant: -16.0).isActive = true
        nicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: replyImageView.leadingAnchor, constant: -24.0).isActive = true
        
        replyImageView.widthAnchor.constraint(equalToConstant: 12.0).isActive = true
        replyImageView.heightAnchor.constraint(equalToConstant: 12.0).isActive = true
        replyImageView.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor, constant: -16.0).isActive = true
        replyImageView.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 8.0).isActive = true
        replyImageView.trailingAnchor.constraint(equalTo: replyCountLabel.leadingAnchor, constant: -4.0).isActive = true
        
        replyCountLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 8.0).isActive = true
        replyCountLabel.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor, constant: -16.0).isActive = true
        replyCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        
        bottomDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        bottomDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
        bottomDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0).isActive = true
        bottomDivider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func resetCell() {
        festivalLabel.text = nil
        titleLabel.text = nil
        detailLabel.text = nil
        nicknameLabel.text = nil
        dateLabel.text = nil
        replyImageView.image = UIImage(systemName: "bubble")
        replyCountLabel.text = nil
    }
}
