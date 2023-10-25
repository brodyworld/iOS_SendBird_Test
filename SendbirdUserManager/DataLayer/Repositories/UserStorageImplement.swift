//
//  UserStorageImplement.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//
// 데이터 저장하는 방법
// Array로 저장
// 장점 : getUsers 받기 쉬움
// 단점 : userId

// Dictionary로 저장. (<- 선택) 검색속도가 빠르니까. getUsers를 받기 힘듬.
// Key : UserId, Value : SBUser
// 장점 : getUser속도가 빠름, loop 사용 가능
// 단점 : 순서가 보장되는가? (순서를 보장해야 되는 이유가 있는가? Array에 쌓이는 순서도 정렬된 상태가 아닐텐데)


// Race Condition을 해결하기 위한 방법
// Custom DispatchQueue 사용 (<- 선택)
// 장점 : 간단함.
// 단점 : Actor를 사용하면 코드가 더 깔끔하고 목적에 맞음.

// Actor 사용
// 장점 : 고유의 쓰레드를 가지고 있기 때문에 Race Condition을 해결하기 위해 나왔기 때문에 용도에 맞음
// 단점 : 사용해본 경험이 많이 없어서 시간이 많이 걸림.
//       테스트해본결과 protocol에서 제공하는 함수를 async로 다 변경해야되며 Tests 코드도 대거 변경해야됨. (이번 과제에서는 비효율적)
import Foundation

class UserStorageImplement: SBUserStorage {
    private var applicationId: String = "defaultAppicationId"
    private let usersCache = NSCache<NSString, NSData>() // Key -> AppId
    private let queue = DispatchQueue(label: "Sendbird.Test.Queue")
    private var timer: DispatchSourceTimer?
    
    init(appId: String) {
        self.applicationId = appId
    }
    
    required init() {
        
    }
    
    var users: [String: SBUser] = [:] {
        didSet {
            updateToCacheWithTimer(users: users)
        }
    }
    
    func updateAppicationId(_ appId: String) {
        guard appId != applicationId else { return }
        usersCache.removeObject(forKey: NSString(string: applicationId)) // 기존 캐시 삭제

        applicationId = appId
        // 계정 변경하거나 다중 계정일 때 사용
//        guard let data = usersCache.object(forKey: NSString(string: self.applicationId)) else { return }
//        guard let decodedUsers = try? JSONDecoder().decode([String: SBUser].self, from: Data(data)) else { return }
//        users = decodedUsers
    }

    func updateToCacheWithTimer(users: [String: SBUser]) {
        if timer != nil {
            timer?.cancel()
            timer = nil
        }
        
        self.timer = DispatchSource.makeTimerSource(queue: queue)
        self.timer?.setEventHandler(handler: { [weak self] in
            guard let `self` = self else { return }
            guard let encodedData = try? JSONEncoder().encode(users) else { return }
            self.usersCache.setObject(NSData(data: encodedData), forKey: NSString(string: self.applicationId))
        })
        
        self.timer?.schedule(deadline: .now() + 1.0)
        self.timer?.resume()
    }
    
    func upsertUser(_ user: SBUser) {
        queue.sync {
            self.users[user.userId] = user
        }
    }
    
    func getUsers() -> [SBUser] {
        queue.sync {
            return self.users.map { $0.value }
        }
    }
    
    func getUsers(for nickname: String) -> [SBUser] {
        queue.sync {
            return self.users.filter { $0.value.nickname == nickname }.map { $0.value }
        }
    }
    
    func getUser(for userId: String) -> (SBUser)? {
        queue.sync {
            return self.users[userId]
        }
    }
    
}
