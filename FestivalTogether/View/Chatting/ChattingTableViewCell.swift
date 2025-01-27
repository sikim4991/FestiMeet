//
//  ChattingTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 11/4/24.
//

import UIKit

class ChattingTableViewCell: UITableViewCell {
    var onResultReport: (() -> Void)?
    
    let myMessageLabel = UILabel()
    let myMessageDateLabel = UILabel()
    let myMessageContainerView = UIView()
    
    let othersNicknameLabel = UILabel()
    let othersProfileImageView = UIImageView()
    let othersMessageLabel = UILabel()
    let othersMessageDateLabel = UILabel()
    let othersMessageContainerView = UIView()

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
        //본인 메시지 레이블
        myMessageLabel.font = .mainFontRegular(size: 12.0)
        myMessageLabel.textColor = .black
        myMessageLabel.clipsToBounds = true
        myMessageLabel.numberOfLines = 0
        myMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //본인 메시지 컨테이너
        myMessageContainerView.backgroundColor = .clear
        myMessageContainerView.layer.borderColor = UIColor.black.cgColor
        myMessageContainerView.layer.borderWidth = 1.0
        myMessageContainerView.layer.cornerRadius = 8.0
        myMessageContainerView.addInteraction(UIContextMenuInteraction(delegate: self))
        myMessageContainerView.isUserInteractionEnabled = true
        myMessageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        //본인 메시지 전송 날짜
        myMessageDateLabel.font = .mainFontRegular(size: 10.0)
        myMessageDateLabel.textColor = .lightGray
        myMessageDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //다른 사람 닉네임 레이블
        othersNicknameLabel.font = .mainFontRegular(size: 12.0)
        othersNicknameLabel.textColor = .black
        othersNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //다른 사람 프로필 이미지
        othersProfileImageView.image = UIImage(resource: .person).withTintColor(.white)
        othersProfileImageView.backgroundColor = .lightGray
        othersProfileImageView.layer.cornerRadius = 20.0
        othersProfileImageView.layer.borderWidth = 0.5
        othersProfileImageView.layer.borderColor = UIColor.systemGray5.cgColor
        othersProfileImageView.contentMode = .scaleAspectFill
        othersProfileImageView.clipsToBounds = true
        othersProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //다른 사람 메시지 레이블
        othersMessageLabel.font = .mainFontRegular(size: 12.0)
        othersMessageLabel.textColor = .black
        othersMessageLabel.numberOfLines = 0
        othersMessageLabel.clipsToBounds = true
        othersMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //다른 사람 메시지 컨테이너
        othersMessageContainerView.backgroundColor = .clear
        othersMessageContainerView.layer.borderColor = UIColor.black.cgColor
        othersMessageContainerView.layer.borderWidth = 1.0
        othersMessageContainerView.layer.cornerRadius = 8.0
        othersMessageContainerView.addInteraction(UIContextMenuInteraction(delegate: self))
        othersMessageContainerView.isUserInteractionEnabled = true
        othersMessageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        //다른 사람 메시지 전송 날짜
        othersMessageDateLabel.font = .mainFontRegular(size: 10.0)
        othersMessageDateLabel.textColor = .lightGray
        othersMessageDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        myMessageContainerView.addSubview(myMessageLabel)
        contentView.addSubview(myMessageDateLabel)
        contentView.addSubview(myMessageContainerView)
        contentView.addSubview(othersNicknameLabel)
        contentView.addSubview(othersProfileImageView)
        othersMessageContainerView.addSubview(othersMessageLabel)
        contentView.addSubview(othersMessageDateLabel)
        contentView.addSubview(othersMessageContainerView)
        
        //AutoLayout 설정
        myMessageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        myMessageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        myMessageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        
        myMessageLabel.leadingAnchor.constraint(equalTo: myMessageContainerView.leadingAnchor, constant: 12.0).isActive = true
        myMessageLabel.topAnchor.constraint(equalTo: myMessageContainerView.topAnchor, constant: 8.0).isActive = true
        myMessageLabel.trailingAnchor.constraint(equalTo: myMessageContainerView.trailingAnchor, constant: -12.0).isActive = true
        myMessageLabel.bottomAnchor.constraint(equalTo: myMessageContainerView.bottomAnchor, constant: -8.0).isActive = true
        
        myMessageDateLabel.trailingAnchor.constraint(equalTo: myMessageContainerView.leadingAnchor, constant: -8.0).isActive = true
        myMessageDateLabel.bottomAnchor.constraint(equalTo: myMessageContainerView.bottomAnchor).isActive = true
        myMessageDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        myMessageDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        othersProfileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        othersProfileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        othersProfileImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        othersProfileImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        othersNicknameLabel.leadingAnchor.constraint(equalTo: othersProfileImageView.trailingAnchor, constant: 8.0).isActive = true
        othersNicknameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        othersNicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        
        othersMessageContainerView.leadingAnchor.constraint(equalTo: othersProfileImageView.trailingAnchor, constant: 8.0).isActive = true
        othersMessageContainerView.topAnchor.constraint(equalTo: othersNicknameLabel.bottomAnchor, constant: 8.0).isActive = true
        othersMessageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        
        othersMessageLabel.leadingAnchor.constraint(equalTo: othersMessageContainerView.leadingAnchor, constant: 12.0).isActive = true
        othersMessageLabel.topAnchor.constraint(equalTo: othersMessageContainerView.topAnchor, constant: 8.0).isActive = true
        othersMessageLabel.trailingAnchor.constraint(equalTo: othersMessageContainerView.trailingAnchor, constant: -12.0).isActive = true
        othersMessageLabel.bottomAnchor.constraint(equalTo: othersMessageContainerView.bottomAnchor, constant: -8.0).isActive = true
        
        othersMessageDateLabel.leadingAnchor.constraint(equalTo: othersMessageContainerView.trailingAnchor, constant: 8.0).isActive = true
        othersMessageDateLabel.bottomAnchor.constraint(equalTo: othersMessageContainerView.bottomAnchor).isActive = true
        othersMessageDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        othersMessageDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func resetCell() {
        onResultReport = nil
        
        myMessageLabel.text = nil
        myMessageDateLabel.text = nil
        othersNicknameLabel.text = nil
        othersProfileImageView.image = UIImage(resource: .person).withTintColor(.white)
        othersMessageLabel.text = nil
        othersMessageDateLabel.text = nil
        
        myMessageLabel.isHidden = false
        myMessageDateLabel.isHidden = false
        myMessageContainerView.isHidden = false
        othersMessageLabel.isHidden = false
        othersNicknameLabel.isHidden = false
        othersMessageDateLabel.isHidden = false
        othersProfileImageView.isHidden = false
        othersMessageContainerView.isHidden = false
    }
}

extension ChattingTableViewCell: UIContextMenuInteractionDelegate {
    //꾹 눌렀을 때
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        //복사하기, 신고하기 메뉴 생성
        return UIContextMenuConfiguration(actionProvider:  { [weak self] (_: [UIMenuElement]) -> UIMenu? in
            let copyAction = UIAction(title: "복사하기") { _ in
                if self?.myMessageLabel.text != nil {
                    UIPasteboard.general.string = self?.myMessageLabel.text
                } else if self?.othersMessageLabel.text != nil {
                    UIPasteboard.general.string = self?.othersMessageLabel.text
                }
            }
            let reportAction = UIAction(title: "신고하기", attributes: .destructive) { _ in
                if self?.othersMessageLabel.text != nil {
                    self?.onResultReport?()
                }
            }
            
            if self?.myMessageLabel.text != nil {
                reportAction.attributes = .hidden
            }
            
            return UIMenu(children: [copyAction, reportAction])
        })
    }
}
