//
//  UserListEntity.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

struct UserListEntity: Codable {
    let users: [UserEntity]
    let next: String?
}

struct CreateUsersEntity: Codable {
    let users: [UserEntity]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        users = try container.decode([UserEntity].self)
    }
}
