//
//  ReplyCountCollectionViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 10/19/24.
//

import UIKit

class ReplyCountCollectionViewCell: UICollectionViewCell {
    let spaceView = UIView()
    let replyCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView() {
        self.backgroundColor = .white
        
        spaceView.backgroundColor = .secondarySystemBackground
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        
        replyCountLabel.text = "댓글 0"
        replyCountLabel.font = .mainFontRegular(size: 12.0)
        replyCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(spaceView)
        self.addSubview(replyCountLabel)
        
        //AutoLayout 설정
        spaceView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        spaceView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        spaceView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        spaceView.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        replyCountLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        replyCountLabel.topAnchor.constraint(equalTo: spaceView.bottomAnchor, constant: 16.0).isActive = true
        replyCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -24.0).isActive = true
        replyCountLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16.0).isActive = true
    }
}
