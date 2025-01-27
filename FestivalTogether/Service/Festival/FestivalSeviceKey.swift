//
//  FestivalSeviceKey.swift
//  FestivalTogether
//
//  Created by SIKim on 1/27/25.
//

import Foundation

let tempKey = Bundle.main.infoDictionary?["FestivalServiceKey"] as! String
let festivalServiceKey = tempKey.replacingOccurrences(of: "__", with: "//")
