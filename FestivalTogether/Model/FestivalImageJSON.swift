//
//  FestivalImageJSON.swift
//  FestivalTogether
//
//  Created by SIKim on 10/1/24.
//

import Foundation

// MARK: - FestivalImageJSON
struct FestivalImageJSON: Codable {
    let response: FestivalImageResponse
}

// MARK: - Response
struct FestivalImageResponse: Codable {
    let header: FestivalImageHeader
    let body: FestivalImageBody
}

// MARK: - Body
struct FestivalImageBody: Codable {
    let items: FestivalImageItems
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct FestivalImageItems: Codable {
    let item: [FestivalImageItem]
}

// MARK: - Item
struct FestivalImageItem: Codable {
    let contentid: String
    let originimgurl: String
    let imgname: String
    let smallimageurl: String
    let cpyrhtDivCD: String
    let serialnum: String

    enum CodingKeys: String, CodingKey {
        case contentid, originimgurl, imgname, smallimageurl
        case cpyrhtDivCD = "cpyrhtDivCd"
        case serialnum
    }
}

// MARK: - Header
struct FestivalImageHeader: Codable {
    let resultCode, resultMsg: String
}
