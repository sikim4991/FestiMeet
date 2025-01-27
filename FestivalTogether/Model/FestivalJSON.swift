//
//  Festival.swift
//  FestivalTogether
//
//  Created by SIKim on 9/23/24.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let festival = try? JSONDecoder().decode(Festival.self, from: jsonData)

// MARK: - FestivalJSON
struct FestivalJSON: Codable {
    let response: FestivalResponse
}

// MARK: - Response
struct FestivalResponse: Codable {
    let header: FestivalHeader
    let body: FestivalBody
}

// MARK: - Body
struct FestivalBody: Codable {
    let items: FestivalItems
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct FestivalItems: Codable {
    let item: [FestivalItem]
}

// MARK: - Item
struct FestivalItem: Codable {
    let addr1, addr2, booktour, cat1: String
    let cat2, cat3, contentid, contenttypeid: String
    let createdtime, eventstartdate, eventenddate: String
    let firstimage, firstimage2: String
    let cpyrhtDivCD, mapx, mapy, mlevel: String
    let modifiedtime, areacode, sigungucode, tel: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case addr1, addr2, booktour, cat1, cat2, cat3, contentid, contenttypeid, createdtime, eventstartdate, eventenddate, firstimage, firstimage2
        case cpyrhtDivCD = "cpyrhtDivCd"
        case mapx, mapy, mlevel, modifiedtime, areacode, sigungucode, tel, title
    }
}

// MARK: - Header
struct FestivalHeader: Codable {
    let resultCode, resultMsg: String
}
