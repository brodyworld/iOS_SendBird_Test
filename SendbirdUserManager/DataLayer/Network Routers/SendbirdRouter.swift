//
//  SendbirdRouter.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation
import Moya

public enum SendbirdRouter {
    case getUsers(nickname: String)
    case getUser(userId: String)
    case createUser(params: UserCreationParams)
    case updateUser(params: UserUpdateParams)
}

// BRODY : 중간에 아이디 바뀌면 apiToken, baseURL다 바뀌어야 됨.
// apiToken, appID를 Singleton에서 들고있으면 불가능함.(중간에 다 삭제를 하던지 해야됨)
// 번거롭지만 Request할 때 apiToken과 appID를 넣어야 될듯
// 장점 : 5개의 Update 요청을 보내고 계정바꿔서 2개의 Update 요청을 보내면 각각의 appID가 잘 update 될것임.
extension SendbirdRouter: TargetType {
    
    var apiToken: String { "f0964228b82d8b0b39497b2fe5261af0774fe4ce" }
    
    public var baseURL: URL {
        guard let url = URL(string: "https://api-E30DE0C6-7F1D-4786-8A4D-795356ADC731.sendbird.com/v3") else { fatalError("Server URL convert Error") }
        return url
    }
    
    public var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUser(let userId):
            return "/users/\(userId)"
        case .createUser:
            return "/users"
        case .updateUser(let params):
            return "/users/\(params.userId)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getUsers:
            return .get
        case .getUser:
            return .get
        case .createUser:
            return .post
        case .updateUser:
            return .put
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getUsers(let nickname):
            var parameters = [String: Any]()
            
            if nickname.count > 0 {
                parameters["nickname"] = nickname
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case .getUser:
            return .requestPlain
        case .createUser(let params):
            let parameters = [
                "user_id": params.userId,
                "nickname": params.nickname,
                "profile_url": params.profileURL ?? "" // BRODY 유저를 만들때는 profile Url이 필수.(없으면 API에서 오류 떨어짐)
            ]

            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .updateUser(let params):
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
