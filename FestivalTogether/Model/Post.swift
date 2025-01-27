//
//  Post.swift
//  FestivalTogether
//
//  Created by SIKim on 10/9/24.
//

import Foundation

struct Post: Codable {
    let id: String
    let userId: String
    let nickname: String
    let profileImageURLString: String?
    let createdDate: Date
    let festivalTitle: String?
    let festivalId: String?
    let title: String
    let detail: String
    let replyCount: Int
    let reportCount: Int
    let reporterIds: [String]
}
