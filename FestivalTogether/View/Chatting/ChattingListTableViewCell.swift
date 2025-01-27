//
//  ChattingListTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 10/31/24.
//

import UIKit

class ChattingListTableViewCell: UITableViewCell {
    var chatImageView = UIImageView()
    let chattingNameLabel = UILabel()
    let chattingMemberCountLabel = UILabel()
    let lastMessageLabel = UILabel()
    let lastMessageDateLabel = UILabel()

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
        //채팅 말풍선 이미지
        chatImageView.image = UIImage(resource: .chat).withTintColor(.lightGray)
        chatImageView.layer.cornerRadius = 20.0
        chatImageView.layer.borderColor = UIColor.lightGray.cgColor
        chatImageView.layer.borderWidth = 2.0
        chatImageView.contentMode = .scaleAspectFit
        chatImageView.clipsToBounds = true
        chatImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //채팅방 이름
        chattingNameLabel.font = .mainFontBold(size: 15.0)
        chattingNameLabel.numberOfLines = 1
        chattingNameLabel.textColor = .black
        chattingNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //채팅 멤버 수
        chattingMemberCountLabel.font = .mainFontRegular(size: 15.0)
        chattingMemberCountLabel.numberOfLines = 1
        chattingMemberCountLabel.textAlignment = .left
        chattingMemberCountLabel.textColor = .black
        chattingMemberCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //마지막 메시지 날짜
        lastMessageDateLabel.font = .mainFontRegular(size: 12.0)
        lastMessageDateLabel.textColor = .secondaryLabel
        lastMessageDateLabel.textAlignment = .right
        lastMessageDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //마지막 메시지 내용
        lastMessageLabel.font = .mainFontRegular(size: 12.0)
        lastMessageLabel.textColor = .secondaryLabel
        lastMessageLabel.numberOfLines = 1
        lastMessageLabel.textAlignment = .left
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(chatImageView)
        contentView.addSubview(chattingNameLabel)
        contentView.addSubview(chattingMemberCountLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(lastMessageDateLabel)
        
        //AutoLayout 설정
        chatImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        chatImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        chatImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        chatImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        chatImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        
        chattingNameLabel.leadingAnchor.constraint(equalTo: chatImageView.trailingAnchor, constant: 16.0).isActive = true
        chattingNameLabel.topAnchor.constraint(equalTo: chatImageView.topAnchor).isActive = true
        chattingNameLabel.trailingAnchor.constraint(equalTo: chattingMemberCountLabel.leadingAnchor, constant: -8.0).isActive = true
        
        chattingMemberCountLabel.centerYAnchor.constraint(equalTo: chattingNameLabel.centerYAnchor).isActive = true
        chattingMemberCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: lastMessageDateLabel.leadingAnchor, constant: -16.0).isActive = true
        
        lastMessageDateLabel.centerYAnchor.constraint(equalTo: chattingMemberCountLabel.centerYAnchor).isActive = true
        lastMessageDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        lastMessageDateLabel.bottomAnchor.constraint(lessThanOrEqualTo: lastMessageLabel.topAnchor, constant: -8.0).isActive = true
        lastMessageDateLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lastMessageDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        lastMessageLabel.leadingAnchor.constraint(equalTo: chatImageView.trailingAnchor, constant: 16.0).isActive = true
        lastMessageLabel.topAnchor.constraint(equalTo: chattingNameLabel.bottomAnchor, constant: 8.0).isActive = true
        lastMessageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        lastMessageLabel.trailingAnchor.constraint(equalTo: lastMessageDateLabel.leadingAnchor, constant: -16.0).isActive = true
        lastMessageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lastMessageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func resetCell() {
        chattingNameLabel.text = nil
        chattingMemberCountLabel.text = nil
        lastMessageLabel.text = nil
        lastMessageDateLabel.text = nil
    }
}
