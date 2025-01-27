//
//  Extension_UIImage.swift
//  FestivalTogether
//
//  Created by SIKim on 9/14/24.
//

import Foundation
import UIKit

extension UIImage {
    ///이미지 리사이징
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
