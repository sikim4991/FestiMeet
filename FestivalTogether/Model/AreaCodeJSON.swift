//
//  AreaCodeJSON.swift
//  FestivalTogether
//
//  Created by SIKim on 9/30/24.
//

import Foundation

// MARK: - AreaCodeJSON
struct AreaCodeJSON: Codable {
    let response: AreaCodeResponse
}

// MARK: - Response
struct AreaCodeResponse: Codable {
    let header: AreaCodeHeader
    let body: AreaCodeBody
}

// MARK: - Body
struct AreaCodeBody: Codable {
    let items: AreaCodeItems
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct AreaCodeItems: Codable {
    let item: [AreaCodeItem]
}

// MARK: - Item
struct AreaCodeItem: Codable {
    let rnum: Int
    let code: String?
    let name: String
}

// MARK: - Header
struct AreaCodeHeader: Codable {
    let resultCode, resultMsg: String
}
