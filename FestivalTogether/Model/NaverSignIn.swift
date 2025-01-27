//
//  NaverSignIn.swift
//  FestivalTogether
//
//  Created by SIKim on 9/23/24.
//

import Foundation

struct NaverSignIn: Codable {
    let resultcode: String
    let message: String
    let response: NaverSignInResponse
}

struct NaverSignInResponse: Codable {
    let id: String
//    let name: String
    let email: String
}
