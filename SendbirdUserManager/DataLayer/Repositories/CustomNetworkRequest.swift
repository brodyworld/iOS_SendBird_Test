//
//  CustomRequest.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/25.
//

import Foundation

struct CreateUserRequest: Request {
    typealias Response = UserEntity
    var router: SendbirdRouter
    var date = Date()
}

struct CreateUsersRequest: Request {
    typealias Response = CreateUsersEntity
    var router: SendbirdRouter
    var date = Date()
}

struct UpdateUserRequest: Request {
    typealias Response = UserEntity
    var router: SendbirdRouter
    var date = Date()
}

struct GetUserRequest: Request {
    typealias Response = UserEntity
    var router: SendbirdRouter
    var date = Date()
}

struct GetUsersRequest: Request {
    typealias Response = UserListEntity
    var router: SendbirdRouter
    var date = Date()
}
