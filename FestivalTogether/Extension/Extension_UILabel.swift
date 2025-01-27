//
//  Extension_UILabel.swift
//  FestivalTogether
//
//  Created by SIKim on 10/2/24.
//

import Foundation
import UIKit

extension UILabel {
    ///텍스트 줄바꿈 간격 조절
    func setLineSpacing(lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing // 행 간격 설정
        
        let attributedString = NSMutableAttributedString(string: text ?? "-")
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        self.attributedText = attributedString
    }
}

