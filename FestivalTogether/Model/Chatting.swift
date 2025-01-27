//
//  Chatting.swift
//  FestivalTogether
//
//  Created by SIKim on 10/31/24.
//

import Foundation
import RealmSwift

struct Chatting: Codable {
    let id: String
    var chattingName: String
    var lastMessage: String?
    var lastMessageDate: Date?
    var memberIds: [String]
    var members: [Member]
}

struct Member: Codable {
    let userId: String
    var nickname: String
    var profileImageURLString: String?
    var startDate: Date
    var lastReadDate: Date
}

struct Message: Codable {
    var senderId: String
    var senderDate: Date
    var senderMessage: String
}

class ChattingForRealm: Object {
    @Persisted var id: String
    @Persisted var senderId: String
    @Persisted var senderDate: Date
    @Persisted var senderMessage: String
    
    convenience init(id: String, senderId: String, senderDate: Date, senderMessage: String) {
        self.init()
        self.id = id
        self.senderId = senderId
        self.senderDate = senderDate
        self.senderMessage = senderMessage
    }
}
