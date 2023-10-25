//
//  Models.swift
//  
//
//  Created by Sendbird
//

import Foundation

// BRODY : Codable 추가
/// User를 생성할때 사용되는 parameter입니다.
/// - Parameters:
///   - userId: 생성될 user id
///   - nickname: 해당 user의 nickname
///   - profileURL: 해당 user의 profile로 사용될 image url
public struct UserCreationParams: Codable {
    public let userId: String
    public let nickname: String
    public let profileURL: String?
        
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(userId, forKey: .userId)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(profileURL ?? "", forKey: .profileURL)

    }
}

/// User를 update할때 사용되는 parameter입니다.
/// - Parameters:
///   - userId: 업데이트할 User의 ID
///   - nickname: 새로운 nickname
///   - profileURL: 새로운 image url
public struct UserUpdateParams {
    public let userId: String
    public let nickname: String?
    public let profileURL: String?
}

// BRODY : Codable 추가
/// Sendbird의 User를 나타내는 객체입니다
public struct SBUser: Codable {
    public init(userId: String, nickname: String? = nil, profileURL: String? = nil) {
        self.userId = userId
        self.nickname = nickname
        self.profileURL = profileURL
    }

    public var userId: String
    public var nickname: String?
    public var profileURL: String?
}
