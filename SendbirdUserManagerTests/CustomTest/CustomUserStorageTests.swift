//
//  CustomUserStorageTests.swift
//  SendbirdUserManagerTests
//
//  Created by Brody Byun on 2023/10/23.
//

import XCTest
@testable import SendbirdUserManager

open class CustomUserStorageTests: XCTestCase {
    open func userStorageType() -> SBUserStorage.Type! {
        return UserStorageImplement.self
    }
    
    public func testInsertSevenAndUpsertUser() {
        let storage = self.userStorageType().init()
        
        (0..<11).forEach {
            storage.upsertUser(SBUser(userId: "\($0)"))
        }
        
        (0..<3).forEach {
            storage.upsertUser(SBUser(userId: "\($0)", nickname: "nickname_\($0)"))
        }

        XCTAssert(storage.getUser(for: "0")?.nickname == "nickname_0")
        XCTAssert(storage.getUser(for: "2")?.nickname == "nickname_2")
        XCTAssertEqual(storage.getUsers().count, 11)
    }
    
}

// MARK: 기본 제공하는 테스트.
extension CustomUserStorageTests {

    public func testSetUser() {
        let storage = self.userStorageType().init()
        
        let user = SBUser(userId: "1")
        storage.upsertUser(user)
        
        XCTAssert(storage.getUser(for: "1")?.userId == "1")
        XCTAssert(storage.getUsers().first?.userId == "1")
    }
    
    public func testSetAndGetUser() {
        let storage = self.userStorageType().init()
        
        let user = SBUser(userId: "1")
        storage.upsertUser(user)
        
        let retrievedUser = storage.getUser(for: user.userId)
        XCTAssertEqual(user.nickname, retrievedUser?.nickname)
    }
    
    public func testGetAllUsers() {
        let storage = self.userStorageType().init()
        
        let users = [SBUser(userId: "1"), SBUser(userId: "2")]
        
        for user in users {
            storage.upsertUser(user)
        }
        
        let retrievedUsers = storage.getUsers()
        XCTAssertEqual(users.count, retrievedUsers.count)
    }
    
    public func testThreadSafety() {
        let storage = self.userStorageType().init()
        
        let user = SBUser(userId: "1")
        
        let expectation = self.expectation(description: "Updating storage from multiple threads")
        expectation.expectedFulfillmentCount = 2
        
        let queue1 = DispatchQueue(label: "com.test.queue1")
        let queue2 = DispatchQueue(label: "com.test.queue2")
        
        queue1.async {
            for _ in 0..<1000 {
                storage.upsertUser(user)
            }
            expectation.fulfill()
        }
        
        queue2.async {
            for _ in 0..<1000 {
                _ = storage.getUser(for: user.userId)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    public func testConcurrentWrites() {
        let storage = self.userStorageType().init()
        
        let expectation = self.expectation(description: "Concurrent writes")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            DispatchQueue.global().async {
                let user = SBUser(userId: "\(i)")
                storage.upsertUser(user)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    public func testConcurrentReads() {
        let storage = self.userStorageType().init()
        
        let user = SBUser(userId: "1")
        storage.upsertUser(user)
        
        let expectation = self.expectation(description: "Concurrent reads")
        expectation.expectedFulfillmentCount = 10
        
        for _ in 0..<10 {
            DispatchQueue.global().async {
                _ = storage.getUser(for: user.userId)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    public func testMixedReadsAndWrites() {
        let storage = self.userStorageType().init()
        
        let expectation = self.expectation(description: "Mixed reads and writes")
        expectation.expectedFulfillmentCount = 20
        
        for i in 0..<10 {
            DispatchQueue.global().async {
                let user = SBUser(userId: "\(i)")
                storage.upsertUser(user)
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = storage.getUser(for: "\(i)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    public func testPerformanceOfSetUser() {
        let storage = self.userStorageType().init()
        
        let user = SBUser(userId: "1")
        
        measure {
            for _ in 0..<1_000_000 {
                storage.upsertUser(user)
            }
        }
    }
    
    public func testPerformanceOfGetUser() {
        let storage = self.userStorageType().init()
        
        let user = SBUser(userId: "1")
        storage.upsertUser(user)
        
        measure {
            for _ in 0..<1_000_000 {
                _ = storage.getUser(for: user.userId)
            }
        }
    }
    
    public func testPerformanceOfGetAllUsers() {
        let storage = self.userStorageType().init()
        
        for i in 0..<1_000 {
            let user = SBUser(userId: "\(i)")
            storage.upsertUser(user)
        }
        
        measure {
            _ = storage.getUsers()
        }
    }

    
    public func testStress() {
        let storage = self.userStorageType().init()
        
        let user = SBUser(userId: "1")
        
        for _ in 0..<10_000 {
            storage.upsertUser(user)
            _ = storage.getUser(for: user.userId)
        }
    }
    
    public func testInterleavedSetAndGet() {
        let storage = self.userStorageType().init()
        
        let expectation = self.expectation(description: "Interleaved set and get")
        expectation.expectedFulfillmentCount = 20
        
        for i in 0..<10 {
            let user = SBUser(userId: "\(i)")
            
            DispatchQueue.global().async {
                storage.upsertUser(user)
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                // Here we will wait for a brief moment to let the setUser operation potentially finish.
                // In real scenarios, this delay might not guarantee the order of operations, but for testing purposes it's useful.
                usleep(1000)
                
                let retrievedUser = storage.getUser(for: "\(i)")
                XCTAssertEqual(user.userId, retrievedUser?.userId)
                XCTAssertEqual(user.nickname, retrievedUser?.nickname)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    public func testBulkSetsAndSingleGet() {
        let storage = self.userStorageType().init()
        
        let setExpectation = self.expectation(description: "Bulk sets")
        setExpectation.expectedFulfillmentCount = 10
        
        let users: [SBUser] = (0..<10).map { SBUser(userId: "\($0)") }
        
        for user in users {
            DispatchQueue.global().async {
                storage.upsertUser(user)
                setExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Now that all set operations have been fulfilled, we retrieve them on a different thread
        DispatchQueue.global().async {
            let retrievedUsers = storage.getUsers()
            
            XCTAssertEqual(users.count, retrievedUsers.count)
//
            for user in users {
                XCTAssertTrue(retrievedUsers.contains(where: { $0.userId == user.userId && $0.nickname == user.nickname }) )
            }
        }
    }
}
