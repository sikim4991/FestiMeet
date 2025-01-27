//
//  ImageDetailCollectionViewCell.swift
//  FestivalTogether
//
//  Created by SIKim on 10/4/24.
//

import UIKit

class ImageDetailCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let scrollView = UIScrollView(frame: UIScreen.main.bounds)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        
        //스크롤뷰 줌 관련
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        imageView.backgroundColor = .black
        imageView.clipsToBounds = true
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetCell() {
        imageView.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
}

extension ImageDetailCollectionViewCell: UIScrollViewDelegate {
    //줌 활성화
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
