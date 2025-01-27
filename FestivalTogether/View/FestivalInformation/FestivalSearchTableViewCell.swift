//
//  FestivalSearchTableViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 10/3/24.
//

import UIKit

class FestivalSearchTableViewCell: UITableViewCell {
    let findingImageView = UIImageView()
    let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellView() {
        //돋보기 이미지
        findingImageView.contentMode = .scaleAspectFit
        findingImageView.tintColor = .signatureTintColor()
        findingImageView.clipsToBounds = true
        findingImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //축제 이름
        titleLabel.font = .mainFontRegular(size: 12.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(findingImageView)
        contentView.addSubview(titleLabel)
        
        //AutoLayout 설정
        findingImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        findingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        findingImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        findingImageView.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
        findingImageView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: findingImageView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: findingImageView.trailingAnchor, constant: 8.0).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16.0).isActive = true
    }
    
    func resetCell() {
        findingImageView.image = nil
        titleLabel.text = nil
    }
    
}
