//
//  SendbirdRouter.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation
import Moya

public enum SendbirdRouter {
    case getUsers(nickname: String, apiToken: String, appId: String)
    case getUser(userId: String, apiToken: String, appId: String)
    case createUser(params: UserCreationParams, apiToken: String, appId: String)
    case createUsers(params: [UserCreationParams], apiToken: String, appId: String)
    case updateUser(params: UserUpdateParams, apiToken: String, appId: String)
}

// BRODY : 중간에 아이디 바뀌면 apiToken, baseURL다 바뀌어야 되기 때문에 apiToken, appID를 파라미터로 전달하기로 결정
extension SendbirdRouter: TargetType {

    var apiToken: String {
        switch self {
        case .getUsers(_, let apiToken, _):
            return apiToken
        case .getUser(_, let apiToken, _):
            return apiToken
        case .createUser(_, let apiToken, _):
            return apiToken
        case .createUsers(_, let apiToken, _):
            return apiToken
        case .updateUser(_, let apiToken, _):
            return apiToken
        }
    }
    
    public var baseURL: URL {
        var applicationId = ""
        switch self {
        case .getUsers(_, _, let appId):
            applicationId = appId
        case .getUser(_, _, let appId):
            applicationId = appId
        case .createUser(_, _, let appId):
            applicationId = appId
        case .createUsers(_, _, let appId):
            applicationId = appId
        case .updateUser(_, _, let appId):
            applicationId = appId
        }
        
        guard let url = URL(string: "https://api-\(applicationId).sendbird.com/v3") else { fatalError("Server URL convert Error") }
        return url
    }
    
    public var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUser(let userId, _, _):
            return "/users/\(userId)"
        case .createUser, .createUsers:
            return "/users"
        case .updateUser(let params, _, _):
            return "/users/\(params.userId)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getUsers:
            return .get
        case .getUser:
            return .get
        case .createUser, .createUsers:
            return .post
        case .updateUser:
            return .put
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getUsers(let nickname, _, _):
            var parameters = [String: Any]()
            
            if nickname.count > 0 {
                parameters["nickname"] = nickname
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case .getUser:
            return .requestPlain
            
        case .createUser(let params, _, _):
            let parameters = [
                "user_id": params.userId,
                "nickname": params.nickname,
                "profile_url": params.profileURL ?? "" // BRODY 유저를 만들때는 profile Url이 필수.(없으면 API에서 오류 떨어짐)
            ]

            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .createUsers(let params, _, _):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            guard let encodedData = try? encoder.encode(params) else { return .requestPlain }

            return .requestData(encodedData)
            
        case .updateUser(let params, _, _):
            var parameters = [
                "user_id": params.userId
            ]

            if let nickname = params.nickname {
                parameters["nickname"] = nickname
            }
            
            if let profileURL = params.profileURL {
                parameters["profile_url"] = profileURL
            }

            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return ["Accept": "application/json",
                "Api-Token": apiToken]
        
    }
}
