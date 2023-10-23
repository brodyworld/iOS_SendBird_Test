//
//  UserEntity.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

struct UserEntity: Codable {
    let userId: String
    let nickname: String?
    let profileURL: String?
    let accessToken: String?
    let hasEverLoggedIn: Bool
    let isActive: Bool
    let isOnline: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname = "nickname"
        case profileURL = "profile_url"
        case accessToken = "access_token"
        case hasEverLoggedIn = "has_ever_logged_in"
        case isActive = "is_active"
        case isOnline = "is_online"
    }
}
