//
//  FestivalDetailJSON.swift
//  FestivalTogether
//
//  Created by SIKim on 10/2/24.
//

import Foundation

// MARK: - Festival
struct FestivalDetailJSON: Codable {
    let response: FestivalDetailResponse
}

// MARK: - Response
struct FestivalDetailResponse: Codable {
    let header: FestivalDetailHeader
    let body: FestivalDetailBody
}

// MARK: - Body
struct FestivalDetailBody: Codable {
    let items: FestivalDetailItems
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct FestivalDetailItems: Codable {
    let item: [FestivalDetailItem]
}

// MARK: - Item
struct FestivalDetailItem: Codable {
    let contentid, contenttypeid, title, createdtime: String
    let firstimage, firstimage2, cpyrhtDivCd: String
    let modifiedtime, tel, telname, homepage: String
    let booktour, addr1, addr2, zipcode: String
    let mapx, mapy, mlevel, overview: String
}

// MARK: - Header
struct FestivalDetailHeader: Codable {
    let resultCode, resultMsg: String
}
