//
//  UserStorageImplement.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation
import UIKit

class UserStorageImplement: SBUserStorage {

    let key: NSString = "SendbirdTest"
    let usersCache = NSCache<NSString, NSData>()
    
    // Array로 저장
    // 장점 : getUsers 받기 쉬움
    // 단점 : userId
    
    // Dictionary로 저장. (<- 이걸로하자.) 검색속도가 빠르니까. getUsers를 받기 힘듬.
    // 장점 : getUser속도가 빠름
    // 단점 : 순서가 보장되는가? (순서를 보장해야 되는 이유가 있는가? Array에 쌓이는 순서도 정렬된 상태가 아닐텐데)
    
    
    var users: [SBUser] {
        get {
            guard let data = usersCache.object(forKey: key) else { return [] }
            guard let decodedUsers = try? JSONDecoder().decode([SBUser].self, from: Data(data)) else { return [] }
            return decodedUsers
        }
    
        set {
            guard let encodedData = try? JSONEncoder().encode(newValue) else { return }
            usersCache.setObject(NSData(data: encodedData), forKey: key)
        }
        
    }
    
    required init() {
        
    }
    
    func upsertUser(_ user: SBUser) {
            
    }
    
    func getUsers() -> [SBUser] {
        return []
    }
    
    func getUsers(for nickname: String) -> [SBUser] {
        return []
    }
    
    func getUser(for userId: String) -> (SBUser)? {
        return nil
    }
    

}
