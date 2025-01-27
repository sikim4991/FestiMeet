//
//  ReplyCollectionReusableView.swift
//  FestivalTogether
//
//  Created by SIKim on 10/17/24.
//

import UIKit

class ReplyCollectionReusableView: UICollectionReusableView {
    let replyNicknameLabel = UILabel()
    let replyDateLabel = UILabel()
    let replyDetailLabel = UILabel()
    var replyOthersButtonConfig = UIButton.Configuration.plain()
    let replyOthersButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView() {
        self.backgroundColor = .white
        
        //댓글 닉네임
        replyNicknameLabel.font = .mainFontBold(size: 12.0)
        replyNicknameLabel.textColor = .black
        replyNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //댓글 작성 날짜
        replyDateLabel.font = .mainFontRegular(size: 12.0)
        replyDateLabel.textColor = .lightGray
        replyDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //댓글 내용
        replyDetailLabel.font = .mainFontRegular(size: 12.0)
        replyDetailLabel.textColor = .black
        replyDetailLabel.numberOfLines = 0
        replyDetailLabel.setLineSpacing(lineSpacing: 4.0)
        replyDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //댓글 메뉴 버튼
        replyOthersButtonConfig.image = UIImage(systemName: "ellipsis")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10.0))
        replyOthersButtonConfig.baseForegroundColor = .black
        replyOthersButton.configuration = replyOthersButtonConfig
        replyOthersButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(replyNicknameLabel)
        self.addSubview(replyDateLabel)
        self.addSubview(replyDetailLabel)
        self.addSubview(replyOthersButton)
        
        //AutoLayout 설정
        replyNicknameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        replyNicknameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        replyDateLabel.leadingAnchor.constraint(equalTo: replyNicknameLabel.trailingAnchor, constant: 8.0).isActive = true
        replyDateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        replyOthersButton.leadingAnchor.constraint(greaterThanOrEqualTo: replyDateLabel.trailingAnchor, constant: 8.0).isActive = true
        replyOthersButton.centerYAnchor.constraint(equalTo: replyDateLabel.centerYAnchor).isActive = true
        replyOthersButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        
        replyDetailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        replyDetailLabel.topAnchor.constraint(equalTo: replyNicknameLabel.bottomAnchor, constant: 16.0).isActive = true
        replyDetailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        replyDetailLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -16.0).isActive = true
    }
}
