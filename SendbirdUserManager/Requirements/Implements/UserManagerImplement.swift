//
//  UserManagerImplement.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

// BRODY : 일단 모든 API값의 응답값이 UserResult이지만 다른 응답값이 나올 수 있어서 확장할 때 어떻게 할지 꼭 생각하자.
class UserManagerImplement: SBUserManager {
    
    var networkClient: SBNetworkClient
    var userStorage: SBUserStorage
    
    var applicationId: String = "E30DE0C6-7F1D-4786-8A4D-795356ADC731" // default
    var apiToken: String = "f0964228b82d8b0b39497b2fe5261af0774fe4ce" // default
    
    static let shared = UserManagerImplement()
    
    required init() {
        networkClient = NetworkClientImplement()
        userStorage = UserStorageImplement()
    }
    
    func initApplication(applicationId: String, apiToken: String) {
        self.applicationId = applicationId
        self.apiToken = apiToken
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        networkClient.request(request: CreateUserRequest(router: .createUser(params: params, apiToken: self.apiToken, appId: self.applicationId))) { result in
            switch result {
            case .success(let userEntity):
                completionHandler?(.success(SBUser(userId: userEntity.userId, nickname: userEntity.nickname, profileURL: userEntity.profileURL)))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
    // BRODY : 중간에 실패하면 재시도를 하던지 해야될듯.
    // BRODY : Test에서 한번에 10개 이상의 계정을 생성하면 에러가 나야된다고 함.
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        guard params.count <= 10 else {
            completionHandler?(.failure(SBError.createUserMoreThan10OnceError))
            return
        }
        Task {
            var createUsers = [SBUser]()
            
            for param in params {
                do {
                    let createUserResponse = await networkClient.request(request: CreateUserRequest(router: .createUser(params: param, apiToken: self.apiToken, appId: self.applicationId)))
                    switch createUserResponse {
                    case .success(let userEntity):
                        createUsers.append(SBUser(userId: userEntity.userId, nickname: userEntity.nickname, profileURL: userEntity.profileURL))
                    case .failure(let failure):
                        print(failure.localizedDescription)
                        return completionHandler?(.failure(failure))
                    }
                }
            }
            
            if createUsers.count == params.count {
                return completionHandler?(.success(createUsers))
            }
        }
    }
    
    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        networkClient.request(request: UpdateUserRequest(router: .updateUser(params: params, apiToken: self.apiToken, appId: self.applicationId))) { result in
            switch result {
            case .success(let userEntity):
                completionHandler?(.success(SBUser(userId: userEntity.userId, nickname: userEntity.nickname, profileURL: userEntity.profileURL)))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        networkClient.request(request: GetUserRequest(router: .getUser(userId: userId, apiToken: self.apiToken, appId: self.applicationId))) { result in
            switch result {
            case .success(let userEntity):
                completionHandler?(.success(SBUser(userId: userEntity.userId, nickname: userEntity.nickname, profileURL: userEntity.profileURL)))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        guard nicknameMatches.isEmpty == false else {
            completionHandler?(.failure(SBError.userListNicknameEmptyError))
            return
        }
        networkClient.request(request: GetUsersRequest(router: .getUsers(nickname: nicknameMatches, apiToken: self.apiToken, appId: self.applicationId))) { result in
            switch result {
            case .success(let userListEntity):
                completionHandler?(.success(userListEntity.users.map{ SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL) }))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
}
