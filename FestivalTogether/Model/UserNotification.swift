//
//  Notification.swift
//  FestivalTogether
//
//  Created by SIKim on 1/8/25.
//

import Foundation

struct UserNotification: Codable {
    let title: String
    let body: String
    let receivedDate: Date
    let postId: String?
}
