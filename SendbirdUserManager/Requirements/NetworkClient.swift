//
//  NetworkClient.swift
//  
//
//  Created by Sendbird
//

import Foundation
import Moya

public protocol Request {
    associatedtype Response: Codable // BRODY : Codable 추가

    var router: SendbirdRouter { get set }
}

public protocol SBNetworkClient {
    init()
    
    /// 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
    
    /// BRODY :  async await 를 위해 추가
    func request<R: Request>(request: R) async -> (Result<R.Response, Error>)

}

struct CreateUserRequest: Request {
    typealias Response = UserEntity
    var router: SendbirdRouter
}

struct UpdateUserRequest: Request {
    typealias Response = UserEntity
    var router: SendbirdRouter
}

struct GetUserRequest: Request {
    typealias Response = UserEntity
    var router: SendbirdRouter
}

struct GetUsersRequest: Request {
    typealias Response = UserListEntity
    var router: SendbirdRouter
}
