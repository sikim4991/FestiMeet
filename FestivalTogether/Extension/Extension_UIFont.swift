//
//  Extension_UIFont.swift
//  FestivalTogether
//
//  Created by SIKim on 9/25/24.
//

import Foundation
import UIKit

extension UIFont {
    ///메인 폰트 ( 얇은 )
    class func mainFontLight(size: CGFloat) -> UIFont {
        UIFont(name: "NanumSquareRoundOTFL", size: size)!
    }
     ///메인 폰트 ( 기본 )
    class func mainFontRegular(size: CGFloat) -> UIFont {
        UIFont(name: "NanumSquareRoundOTFR", size: size)!
    }
    
    ///메인 폰트 ( 두꺼운  )
    class func mainFontBold(size: CGFloat) -> UIFont {
        UIFont(name: "NanumSquareRoundOTFB", size: size)!
    }
    
    ///메인 폰트 ( 아주 두꺼운 )
    class func mainFontExtraBold(size: CGFloat) -> UIFont {
        UIFont(name: "NanumSquareRoundOTFEB", size: size)!
    }
}
