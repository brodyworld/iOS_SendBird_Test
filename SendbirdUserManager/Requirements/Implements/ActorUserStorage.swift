//
//  ActorUserStorage.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/23.
// 사용하지는 않지만 actor로 변환하는 도중에 멈춤.

import Foundation

//actor ActorUserStorage: SBUserStorage {
//    
//    actor ActorUser {
//        var userDictionary = [String: SBUser]()
//        
//        func upsertUser(_ user: SBUser) {
//            self.userDictionary[user.userId] = user
//        }
//        
//        func getUsers() -> [SBUser] {
//            return self.userDictionary.map { $0.value }
//        }
//        
//        func getUser(_ userId: String) -> SBUser? {
//            return self.userDictionary[userId]
//        }
//        
//    }
//
//    nonisolated func updateAppicationId(_ appId: String) {
//        
//    }
//
//    var actorUser = ActorUser()
//    
//    nonisolated func getUsers() -> [SBUser] {
//        let users = Task {
//            return await actorUser.getUsers()
////            users = await actorUser.getUsers()
////            return users
//        }
//    }
//    
//    func getUser(for userId: String) -> (SBUser)? {
//        Task {
//            return await actorUser.getUser(userId: userId)
//        }
//    }
//    
//    func upsertUser(_ user: SBUser) {
//        Task {
//            await actorUser.upsertUser()
//        }
//    }
//    
//    func getUsers(for nickname: String) -> [SBUser] {
//        return self.cache.filter { $0.value.nickname == nickname }.map { $0.value }
//    }
//    
//
//}
