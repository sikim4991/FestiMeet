//
//  Reply.swift
//  FestivalTogether
//
//  Created by SIKim on 10/9/24.
//

import Foundation

struct Reply: Codable, Equatable {
    let id: String
    let postId: String
    let userId: String
    let nickname: String
    let createdDate: Date
    let detail: String
    let reportCount: Int
    let reporterIds: [String]
}
