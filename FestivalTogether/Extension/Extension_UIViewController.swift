//
//  Extension_UIViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 10/20/24.
//

import Foundation
import UIKit

extension UIViewController {
    ///주변 뷰를 탭하여 키보드 숨김
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    ///키보드 숨김
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
