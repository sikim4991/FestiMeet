//
//  User.swift
//  FestivalTogether
//
//  Created by SIKim on 10/9/24.
//

import Foundation

struct User: Codable {
    let id: String
    var nickname: String
    var profileImageURLString: String?
    let email: String
    var notificationCheckedDate: Date
    var reportCount: Int
    var reporterIds: [String]
    var notificationToken: String
}
