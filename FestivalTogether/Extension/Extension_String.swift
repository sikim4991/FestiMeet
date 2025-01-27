//
//  Extension_String.swift
//  FestivalTogether
//
//  Created by SIKim on 10/4/24.
//

import Foundation

extension String {
    ///html 문자가 섞인 것을 제거
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else { return nil }
        
        let options: [NSAttributedString.DocumentReadingOptionKey:Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString.string)
    }
}
