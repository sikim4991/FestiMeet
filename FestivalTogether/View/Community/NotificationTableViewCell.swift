//
//  NotificationTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 1/9/25.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let receivedDateLabel = UILabel()
    
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
        //알림 제목
        titleLabel.textColor = .black
        titleLabel.font = .mainFontBold(size: 14.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //알림 내용
        bodyLabel.textColor = .black
        bodyLabel.font = .mainFontRegular(size: 14.0)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //알림 날짜
        receivedDateLabel.textColor = .lightGray
        receivedDateLabel.font = .mainFontRegular(size: 12.0)
        receivedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(receivedDateLabel)
        
        //AutoLayout 설정
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        
        bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        
        receivedDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        receivedDateLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8.0).isActive = true
        receivedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        receivedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
    }
    
    func resetCell() {
        titleLabel.text = nil
        bodyLabel.text = nil
        receivedDateLabel.text = nil
    }
}
