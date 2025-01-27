//
//  ReplyCommentCollectionViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 10/15/24.
//

import UIKit

class ReplyCommentCollectionViewCell: UICollectionViewCell {
    let replyCommentArrowImageView = UIImageView()
    let replyCommentNicknameLabel = UILabel()
    let replyCommentDetailLabel = UILabel()
    let replyCommentDateLabel = UILabel()
    var replyCommentOthersButtonConfig = UIButton.Configuration.plain()
    let replyCommentOthersButton = UIButton()
    let divider = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
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
        self.backgroundColor = .white
        
        //대댓글 표시용 화살표 이미지
        replyCommentArrowImageView.image = UIImage(systemName: "arrow.turn.down.right")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12.0))
        replyCommentArrowImageView.tintColor = .black
        replyCommentArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //대댓글 닉네임
        replyCommentNicknameLabel.font = .mainFontBold(size: 12.0)
        replyCommentNicknameLabel.textColor = .black
        replyCommentNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //대댓글 작성 날짜
        replyCommentDateLabel.font = .mainFontRegular(size: 12.0)
        replyCommentDateLabel.textColor = .lightGray
        replyCommentDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //대댓글 내용
        replyCommentDetailLabel.font = .mainFontRegular(size: 12.0)
        replyCommentDetailLabel.textColor = .black
        replyCommentDetailLabel.numberOfLines = 0
        replyCommentDetailLabel.setLineSpacing(lineSpacing: 4.0)
        replyCommentDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //대댓글 메뉴 버튼
        replyCommentOthersButtonConfig.image = UIImage(systemName: "ellipsis")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10.0))
        replyCommentOthersButtonConfig.baseForegroundColor = .black
        replyCommentOthersButton.configuration = replyCommentOthersButtonConfig
        replyCommentOthersButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(replyCommentArrowImageView)
        self.addSubview(replyCommentNicknameLabel)
        self.addSubview(replyCommentDateLabel)
        self.addSubview(replyCommentDetailLabel)
        self.addSubview(replyCommentOthersButton)
        
        //AutoLayout 설정
        replyCommentArrowImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        replyCommentArrowImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        replyCommentNicknameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 48.0).isActive = true
        replyCommentNicknameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        replyCommentDateLabel.leadingAnchor.constraint(equalTo: replyCommentNicknameLabel.trailingAnchor, constant: 8.0).isActive = true
        replyCommentDateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        replyCommentOthersButton.leadingAnchor.constraint(greaterThanOrEqualTo: replyCommentDateLabel.trailingAnchor, constant: 8.0).isActive = true
        replyCommentOthersButton.centerYAnchor.constraint(equalTo: replyCommentDateLabel.centerYAnchor).isActive = true
        replyCommentOthersButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        
        replyCommentDetailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 48.0).isActive = true
        replyCommentDetailLabel.topAnchor.constraint(equalTo: replyCommentNicknameLabel.bottomAnchor, constant: 16.0).isActive = true
        replyCommentDetailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        replyCommentDetailLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -16.0).isActive = true
    }
    
    func resetCell() {
        replyCommentNicknameLabel.text = nil
        replyCommentDetailLabel.text = nil
        replyCommentDateLabel.text = nil
    }
}
