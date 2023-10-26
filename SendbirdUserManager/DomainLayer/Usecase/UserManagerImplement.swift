//
//  UserManagerImplement.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

class UserManagerImplement: SBUserManager {
    
    var networkClient: SBNetworkClient
    var userStorage: SBUserStorage
    
    var applicationId: String = "E30DE0C6-7F1D-4786-8A4D-795356ADC731" // default
    var apiToken: String = "f0964228b82d8b0b39497b2fe5261af0774fe4ce" // default
    
    var lastPostDate: Date?
    var lastGetDates = [Date]()
    static let shared = UserManagerImplement()
    
    required init() {
        networkClient = NetworkClientImplement()
        userStorage = UserStorageImplement(appId: applicationId)
    }
    
    func initApplication(applicationId: String, apiToken: String) {
        self.applicationId = applicationId
        self.apiToken = apiToken
        userStorage.updateAppicationId(applicationId)
    }
    
    func isPostRateLimitPass(_ date: Date) -> Bool {
        if let lastPostDate,
           date.timeIntervalSince1970 - lastPostDate.timeIntervalSince1970 < 1 {
            return false
        } else {
            self.lastPostDate = date
            return true
        }
    }
    
    func isGetRateLimitPass(_ date: Date) -> Bool {
        let now = Date()
        lastGetDates = lastGetDates.filter({
            return $0.timeIntervalSince1970 - now.timeIntervalSince1970 < 1
        })
        
        if lastGetDates.count >= 10 {
            return false
        } else {
            lastGetDates.append(date)
            return true
        }
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        let request = CreateUserRequest(router: .createUser(params: params, apiToken: self.apiToken, appId: self.applicationId))
        guard self.isPostRateLimitPass(request.date) == true else {
            completionHandler?(.failure(SBError.postRateLimitError))
            return
        }
        
        guard params.userId.count <= 80 else {
            completionHandler?(.failure(SBError.maximumUserIdLengthError))
            return
        }
        
        guard params.nickname.count <= 80 else {
            completionHandler?(.failure(SBError.maximumNicknameLengthError))
            return
        }
        
        guard params.profileURL?.count ?? 0 <= 2048 else {
            completionHandler?(.failure(SBError.maximumProfileUrlLengthError))
            return
        }

        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let userEntity):
                let user = SBUser(userId: userEntity.userId, nickname: userEntity.nickname, profileURL: userEntity.profileURL)
                self?.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        let request = CreateUsersRequest(router: .createUsers(params: params, apiToken: self.apiToken, appId: self.applicationId))

        guard params.count <= 10 else {
            completionHandler?(.failure(SBError.createUserMoreThan10OnceError))
            return
        }

        guard self.isPostRateLimitPass(request.date) == true else {
            completionHandler?(.failure(SBError.postRateLimitError))
            return
        }
        
        for param in params {
            guard param.userId.count <= 80 else {
                completionHandler?(.failure(SBError.maximumUserIdLengthError))
                return
            }
            
            guard param.nickname.count <= 80 else {
                completionHandler?(.failure(SBError.maximumNicknameLengthError))
                return
            }
            
            guard param.profileURL?.count ?? 0 <= 2048 else {
                completionHandler?(.failure(SBError.maximumProfileUrlLengthError))
                return
            }
        }
        
        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let usersEntity):
                let users = usersEntity.users.map {
                    let user = SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL)
                    self?.userStorage.upsertUser(user)
                    return user
                }
                completionHandler?(.success(users))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        networkClient.request(request: UpdateUserRequest(router: .updateUser(params: params, apiToken: self.apiToken, appId: self.applicationId))) { [weak self] result in
            switch result {
            case .success(let userEntity):
                let user = SBUser(userId: userEntity.userId, nickname: userEntity.nickname, profileURL: userEntity.profileURL)
                self?.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        let request = GetUserRequest(router: .getUser(userId: userId, apiToken: self.apiToken, appId: self.applicationId))
        if let user = userStorage.getUser(for: userId) {
            completionHandler?(.success(user))
            return
        }
        
        guard self.isGetRateLimitPass(request.date) == true else {
            completionHandler?(.failure(SBError.getRateLimitError))
            return
        }
        
        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let userEntity):
                let user = SBUser(userId: userEntity.userId, nickname: userEntity.nickname, profileURL: userEntity.profileURL)
                self?.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        let request = GetUsersRequest(router: .getUsers(nickname: nicknameMatches, apiToken: self.apiToken, appId: self.applicationId))
        
        guard nicknameMatches.isEmpty == false else {
            completionHandler?(.failure(SBError.userListNicknameEmptyError))
            return
        }
        
        guard self.isGetRateLimitPass(request.date) == true else {
            completionHandler?(.failure(SBError.getRateLimitError))
            return
        }
        
        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let userListEntity):
                let users = userListEntity.users.map{ SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL) }
                users.forEach {
                    self?.userStorage.upsertUser($0)
                }
                completionHandler?(.success(users))
            case .failure(let failure):
                completionHandler?(.failure(failure))
            }
        }
    }
    
}
