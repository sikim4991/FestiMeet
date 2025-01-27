//
//  FestivalIntroJSON.swift
//  FestivalTogether
//
//  Created by SIKim on 10/2/24.
//

import Foundation

// MARK: - Festival
struct FestivalIntroJSON: Codable {
    let response: FestivalIntroResponse
}

// MARK: - Response
struct FestivalIntroResponse: Codable {
    let header: FestivalIntroHeader
    let body: FestivalIntroBody
}

// MARK: - Body
struct FestivalIntroBody: Codable {
    let items: FestivalIntroItems
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct FestivalIntroItems: Codable {
    let item: [FestivalIntroItem]
}

// MARK: - Item
struct FestivalIntroItem: Codable {
    let contentid, contenttypeid, sponsor1, sponsor1tel: String
    let sponsor2, sponsor2tel, eventenddate, playtime: String
    let eventplace, eventhomepage, agelimit, bookingplace: String
    let placeinfo, subevent, program, eventstartdate: String
    let usetimefestival, discountinfofestival, spendtimefestival, festivalgrade: String
}

// MARK: - Header
struct FestivalIntroHeader: Codable {
    let resultCode, resultMsg: String
}

