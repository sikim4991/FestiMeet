//
//  Extension_UIColor.swift
//  FestivalTogether
//
//  Created by SIKim on 9/14/24.
//

import Foundation
import UIKit

extension UIColor {
    ///색상 헥스코드 변환
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    ///시그니처 틴트 색상
    static func signatureTintColor() -> UIColor {
        UIColor(hexCode: "F88379")
    }
    
    ///시그니처 배경 색상
    static func signatureBackgroundColor() -> UIColor {
        UIColor(hexCode: "FFD580")
    }
}
