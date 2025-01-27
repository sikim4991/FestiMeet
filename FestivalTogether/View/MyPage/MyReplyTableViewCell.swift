//
//  MyReplyTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 10/26/24.
//

import UIKit

class MyReplyTableViewCell: UITableViewCell {
    let replyDetailLabel = UILabel()
    let dateLabel = UILabel()
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
        //댓글 레이블
        replyDetailLabel.font = .mainFontBold(size: 15.0)
        replyDetailLabel.textColor = .black
        replyDetailLabel.numberOfLines = 0
        replyDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //댓글 날짜
        dateLabel.font = .mainFontRegular(size: 12.0)
        dateLabel.textColor = .lightGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomDivider.backgroundColor = .systemGray5
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(replyDetailLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bottomDivider)
        
        //AutoLayout 설정
        replyDetailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        replyDetailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        replyDetailLabel.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor, constant: -16.0).isActive = true
        replyDetailLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.trailingAnchor, constant: -24.0).isActive = true
        
        dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: bottomDivider.topAnchor, constant: -16.0).isActive = true
        
        bottomDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
        bottomDivider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0).isActive = true
        bottomDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
    
    func resetCell() {
        replyDetailLabel.text = nil
        dateLabel.text = nil
    }
}
