//
//  FestivalTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 9/27/24.
//

import UIKit

class FestivalTableViewCell: UITableViewCell {
    let mainImageView = UIImageView()
    let titleLabel = UILabel()
    let startDateTitle = UILabel()
    let endDateTitle = UILabel()
    let startDateLabel = UILabel()
    let endDateLabel = UILabel()
    let addressLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setCellView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellView() {
        //축제 이미지
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 12.0
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 이름
        titleLabel.font = .mainFontBold(size: 15.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //시작날짜
        startDateTitle.font = .mainFontRegular(size: 12.0)
        startDateTitle.textColor = .systemGray2
        startDateTitle.translatesAutoresizingMaskIntoConstraints = false
        
        startDateLabel.font = .mainFontRegular(size: 12.0)
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //종료날짜
        endDateTitle.font = .mainFontRegular(size: 12.0)
        endDateTitle.textColor = .systemGray2
        endDateTitle.translatesAutoresizingMaskIntoConstraints = false
        
        endDateLabel.font = .mainFontRegular(size: 12.0)
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //주소
        addressLabel.font = .mainFontRegular(size: 12.0)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(mainImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(startDateTitle)
        contentView.addSubview(startDateLabel)
        contentView.addSubview(endDateTitle)
        contentView.addSubview(endDateLabel)
        contentView.addSubview(addressLabel)
        
        //AutoLayout 설정
        mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
        mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        mainImageView.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
        mainImageView.heightAnchor.constraint(equalToConstant: 90.0).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: 16.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16.0).isActive = true
        
        startDateTitle.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: 16.0).isActive = true
        startDateTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0).isActive = true
        
        startDateLabel.leadingAnchor.constraint(equalTo: startDateTitle.trailingAnchor, constant: 2.0).isActive = true
        startDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0).isActive = true
        startDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16.0).isActive = true
        
        endDateTitle.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: 16.0).isActive = true
        endDateTitle.topAnchor.constraint(equalTo: startDateTitle.bottomAnchor, constant: 8.0).isActive = true
        
        endDateLabel.leadingAnchor.constraint(equalTo: endDateTitle.trailingAnchor, constant: 2.0).isActive = true
        endDateLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 8.0).isActive = true
        endDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16.0).isActive = true
        
        addressLabel.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: 16.0).isActive = true
        addressLabel.topAnchor.constraint(equalTo: endDateTitle.bottomAnchor, constant: 8.0).isActive = true
        addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0).isActive = true
        addressLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        
    }
    
    func resetCell() {
        mainImageView.image = nil
        titleLabel.text = nil
        startDateLabel.text = nil
        addressLabel.text = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
}
