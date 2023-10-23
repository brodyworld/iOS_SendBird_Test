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
