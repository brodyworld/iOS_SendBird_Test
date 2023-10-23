//
//  UserManagerBase2Tests.swift
//  SendbirdUserManagerTests
//
//  Created by Brody Byun on 2023/10/21.
//

import XCTest
@testable import SendbirdUserManager

open class UserManagerBase2Tests: XCTestCase {
    open func userManagerType() -> SBUserManager.Type! {
        return UserManagerImplement.self
    }
    
    // AppID1 App에 연결하여 1 유저를 만든 후 AppID2 App으로 연결 후 UserStorage에 유저가 없는지 확인하는 테스트
    public func testInitApplicationWithDifferentAppIdClearsData() {
        let userManager = userManagerType().init()
        
        // First init
        userManager.initApplication(applicationId: "AppID1", apiToken: "Token1")
        let initialUser = UserCreationParams(userId: "1", nickname: "Initial", profileURL: nil)
        userManager.createUser(params: initialUser) { _ in }
        
        // Second init with a different App ID
        userManager.initApplication(applicationId: "AppID2", apiToken: "Token2")
        
        // Check if the data is cleared
        let users = userManager.userStorage.getUsers()
        XCTAssertEqual(users.count, 0, "Data should be cleared after initializing with a different Application ID")
    }

    // CreateUser 기본테스트
    public func testCreateUser() {
        let userManager = userManagerType().init()

        let params = UserCreationParams(userId: "1", nickname: "John Doe", profileURL: nil)
        let expectation = self.expectation(description: "Wait for user creation")
        
        userManager.createUser(params: params) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
                XCTAssertEqual(user.nickname, "John Doe")
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Create Users 기본 테스트. (순서가 맞는지)
    public func testCreateUsers() {
        let userManager = userManagerType().init()

        let params1 = UserCreationParams(userId: "1", nickname: "John", profileURL: nil)
        let params2 = UserCreationParams(userId: "2", nickname: "Jane", profileURL: nil)
        
        let expectation = self.expectation(description: "Wait for users creation")
    
        userManager.createUsers(params: [params1, params2]) { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 2)
                XCTAssertEqual(users[0].nickname, "John")
                XCTAssertEqual(users[1].nickname, "Jane")
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Create User -> Update User 기본 테스트
    public func testUpdateUser() {
        let userManager = userManagerType().init()

        let initialParams = UserCreationParams(userId: "1", nickname: "InitialName", profileURL: nil)
        let updatedParams = UserUpdateParams(userId: "hello", nickname: "UpdatedName", profileURL: nil)
        
        let expectation = self.expectation(description: "Wait for user update")
        
        userManager.createUser(params: initialParams) { creationResult in
            switch creationResult {
            case .success(_):
                userManager.updateUser(params: updatedParams) { updateResult in
                    switch updateResult {
                    case .success(let updatedUser):
                        XCTAssertEqual(updatedUser.nickname, "UpdatedName")
                    case .failure(let error):
                        XCTFail("Failed with error: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Create User -> Get User 기본 테스트
    public func testGetUser() {
        let userManager = userManagerType().init()

        let params = UserCreationParams(userId: "1", nickname: "John", profileURL: nil)
        
        let expectation = self.expectation(description: "Wait for user retrieval")
        
        userManager.createUser(params: params) { creationResult in
            switch creationResult {
            case .success(let createdUser):
                userManager.getUser(userId: createdUser.userId) { getResult in
                    switch getResult {
                    case .success(let retrievedUser):
                        XCTAssertEqual(retrievedUser.nickname, "John")
                    case .failure(let error):
                        XCTFail("Failed with error: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    public func testGetUsersWithNicknameFilter() {
        let userManager = userManagerType().init()

        let params1 = UserCreationParams(userId: "1", nickname: "John", profileURL: nil)
        let params2 = UserCreationParams(userId: "2", nickname: "Jane", profileURL: nil)
        
        let expectation = self.expectation(description: "Wait for users retrieval with nickname filter")
        
        userManager.createUsers(params: [params1, params2]) { creationResult in
            switch creationResult {
            case .success(_):
                userManager.getUsers(nicknameMatches: "John") { getResult in
                    switch getResult {
                    case .success(let users):
                        XCTAssertEqual(users.count, 1)
                        XCTAssertEqual(users[0].nickname, "John")
                    case .failure(let error):
                        XCTFail("Failed with error: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test that trying to create more than 10 users at once should fail
    // 한번에 10개 이상의 Create User를 하면 오류가 발생되어야 함.
    public func testCreateUsersLimit() {
        let userManager = userManagerType().init()

        let users = (0..<11).map { UserCreationParams(userId: "\($0)", nickname: "User\($0)", profileURL: nil) }
        
        let expectation = self.expectation(description: "Wait for users creation with limit")
        
        userManager.createUsers(params: users) { result in
            switch result {
            case .success(_):
                XCTFail("Shouldn't successfully create more than 10 users at once")
            case .failure(let error):
                // Ideally, check for a specific error related to the limit
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test race condition when simultaneously trying to update and fetch a user
    // Update와 Get를 글로벌스레드로 보내면 레이스컨디션이 발생하지 않는지
    
    public func testUpdateUserRaceCondition() {
        let userManager = userManagerType().init()

        let initialParams = UserCreationParams(userId: "1", nickname: "InitialName", profileURL: nil)
        let updatedParams = UserUpdateParams(userId: "hello", nickname: "UpdatedName", profileURL: nil)
        
        let expectation1 = self.expectation(description: "Wait for user update")
        let expectation2 = self.expectation(description: "Wait for user retrieval")
        
        userManager.createUser(params: initialParams) { creationResult in
            guard let createdUser = try? creationResult.get() else {
                XCTFail("Failed to create user")
                return
            }
            
            DispatchQueue.global().async {
                userManager.updateUser(params: updatedParams) { _ in
                    expectation1.fulfill()
                }
            }
            
            DispatchQueue.global().async {
                userManager.getUser(userId: createdUser.userId) { getResult in
                    if case .success(let user) = getResult {
                        XCTAssertTrue(user.nickname == "InitialName" || user.nickname == "UpdatedName")
                    } else {
                        XCTFail("Failed to retrieve user")
                    }
                    expectation2.fulfill()
                }
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 10.0)
    }
    
    // Test for potential deadlock situations
    // Get 을 글로벌 스레드로 보내면 데드락이 발생하는지
    public func testPotentialDeadlockWhenFetchingUsers() {
        let userManager = userManagerType().init()

        let expectation = self.expectation(description: "Detect potential deadlocks when fetching users")

        DispatchQueue.global().async {
            userManager.getUsers(nicknameMatches: "John") { _ in
                expectation.fulfill()
            }
        }

        DispatchQueue.global().async {
            userManager.getUsers(nicknameMatches: "Jane") { _ in
                // nothing to do here
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
    // Test for edge cases where the nickname to be matched is either empty or consists of spaces
    // getUsers에서 닉네임이 없을 때 처리
    public func testGetUsersWithEmptyNickname() {
        let userManager = userManagerType().init()

        let expectation = self.expectation(description: "Wait for users retrieval with empty nickname filter")
        
        userManager.getUsers(nicknameMatches: "") { result in
            if case .failure(let error) = result {
                // Ideally, check for a specific error related to the invalid nickname
                XCTAssertNotNil(error)
            } else {
                XCTFail("Fetching users with empty nickname should not succeed")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Free Trial에서는 GET은 1초에 10개까지만 가능함.
    public func testRateLimitGetUser() {
        let userManager = userManagerType().init()
//        let expectation = self.expectation(description: "Wait for testRateLimitGetUser")

        // Concurrently get user info for 11 users
        let dispatchGroup = DispatchGroup()
        var results: [UserResult] = []
        
        for i in 0..<11 {
            dispatchGroup.enter()
            userManager.getUser(userId: "\(i)") { result in
                switch result {
                case .success(let user):
                    print(user.userId)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                results.append(result)
                dispatchGroup.leave()
            }
            
        }

        
//        dispatchGroup.notify(queue: .main) {
//            // 여기서 결과를 처리하거나 다음 작업을 수행합니다.
//            let successResults = results.filter {
//                if case .success = $0 { return true }
//                return false
//            }
//            let rateLimitResults = results.filter {
//                if case .failure(let error) = $0 { return true }
//                return false
//            }
//
//            XCTAssertEqual(successResults.count, 10)
//            XCTAssertEqual(rateLimitResults.count, 1)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 10.0)

        
                    dispatchGroup.wait()
                    // Expect 10 successful and 1 rateLimitExceeded response
                    let successResults = results.filter {
                        if case .success = $0 { return true }
                        return false
                    }
                    let rateLimitResults = results.filter {
                        if case .failure(let error) = $0 { return true }
                        return false
                    }
        
                    XCTAssertEqual(successResults.count, 10)
                    XCTAssertEqual(rateLimitResults.count, 1)
    }

    public func testRateLimitCreateUser() {
        let userManager = userManagerType().init()
        
        // Concurrently create 11 users
        let dispatchGroup = DispatchGroup()
        var results: [UserResult] = []
        let params = UserCreationParams(userId: "JohnDoe", nickname: "JohnDoe", profileURL: nil)

        for _ in 0..<11 {
            dispatchGroup.enter()
            userManager.createUser(params: params) { result in
                results.append(result)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()

        // Assess the results
        let successResults = results.filter {
            if case .success = $0 { return true }
            return false
        }
        
        let rateLimitResults = results.filter {
            if case .failure(_) = $0 { return true }
            return false
        }

        XCTAssertEqual(successResults.count, 10)
        XCTAssertEqual(rateLimitResults.count, 1)
    }
    
    // 6개를 보내고 6개를 한번더 보냈으니까 10개가 넘어서 뒤에꺼 6개를 버린다?
    //
    public func testRateLimitCreateUsers() {
        let userManager = userManagerType().init()

        let paramsArray = [UserCreationParams(userId: "JohnDoe", nickname: "JohnDoe", profileURL: nil), UserCreationParams(userId: "JaneDoe", nickname: "JaneDoe", profileURL: nil)]

        // Concurrently create 6 batches of users (to exceed the limit with 12 requests)
        let dispatchGroup = DispatchGroup()
        var results: [UsersResult] = []

        for _ in 0..<6 {
            dispatchGroup.enter()
            userManager.createUsers(params: paramsArray) { result in
                results.append(result)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()

        // Assess the results
        let successResults = results.filter {
            if case .success = $0 { return true }
            return false
        }
        let rateLimitResults = results.filter {
            if case .failure(_) = $0 { return true }
            return false
        }

        XCTAssertEqual(successResults.count, 5) // 5 successful batch creations
        XCTAssertEqual(rateLimitResults.count, 1) // 1 rate-limited batch creation
    }
    
    public func testRateLimitUpdateUser() {
        let userManager = userManagerType().init()
        
        let updateParams = UserUpdateParams(userId: "hello", nickname: "NewNick", profileURL: nil)

        // Concurrently update 11 users
        let dispatchGroup = DispatchGroup()
        var results: [UserResult] = []

        for _ in 0..<11 {
            dispatchGroup.enter()
            userManager.updateUser(params: updateParams) { result in
                results.append(result)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()

        // Assess the results
        let successResults = results.filter {
            if case .success = $0 { return true }
            return false
        }
        let rateLimitResults = results.filter {
            if case .failure(_) = $0 { return true }
            return false
        }

        XCTAssertEqual(successResults.count, 10)
        XCTAssertEqual(rateLimitResults.count, 1)
    }
}
