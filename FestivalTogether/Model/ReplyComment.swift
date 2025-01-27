//
//  ReplyComment.swift
//  FestivalTogether
//
//  Created by SIKim on 10/9/24.
//

import Foundation

struct ReplyComment: Codable, Equatable {
    let id: String
    let postId: String
    let replyId: String
    let userId: String
    let nickname: String
    let createdDate: Date
    let detail: String
    let reportCount: Int
    let reporterIds: [String]
}
