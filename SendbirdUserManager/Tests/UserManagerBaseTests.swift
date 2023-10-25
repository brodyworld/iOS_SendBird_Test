//
//  UserManagerBaseTests.swift
//  SendbirdUserManager
//
//  Created by Sendbird
//

import Foundation
import XCTest

/// Unit Testing을 위해 제공되는 base test suite입니다.
/// 사용을 위해서는 해당 클래스를 상속받고,
/// `open func userManagerType() -> SBUserManager.Type!`를 override한뒤, 본인이 구현한 SBUserManager의 타입을 반환하도록 합니다.
open class UserManagerBaseTests: XCTestCase {
    open func userManagerType() -> SBUserManager.Type! {
        return nil
    }
    
    // AppID1 App에 연결하여 1 유저를 만든 후 AppID2 App으로 연결 후 UserStorage에 유저가 없는지 확인하는 테스트
    // 기대값 : AppID1을 AppID2로 변경할 때 캐시데이터를 삭제해야 되므로 유저가 있으면 안됨.
    // 결과  : Pass
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
    
    // CreateUser가 잘 작동하는지 테스트
    // 기대값 : userId 1이 없을 때 createUser가 잘 작동함.
    // 결 과 : Pass
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
    
    // 다수의 계정을 생성할 때 순서대로 잘 생성이 되는지 확인하는 테스트
    // 기대값 : 다수의 계정을 한번에 생성하고 순서대로 생성되어야함.
    // 결 과 : Pass
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
    
    // 계정을 생성하고 다른 계정을 업데이트 하는데 문제가 없는지 확인하는 테스트
    // 기대값 : userId 1은 잘 생성이되고 hello 계정은 잘 업데이트 되어야함.
    // 결 과 : Pass
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
    
    // 계정을 불러오는데 문제가 없는지 확인하는 테스트
    // 기대값 : 유저를 잘 불러옴
    // 결 과 : Pass
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
    
    // 다수의 계정을 만들고 nickname으로 유저목록을 가져올 때 잘 가져오는지 확인하는 테스트
    // 기대값 : 1,2 계정을 만들고 1계정을 가져옴.
    // 결 과 : Pass
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
    // 한번에 10개 이상의 유저를 만들수 있는지 확인하는 테스트
    // 기대값 : 10개 이상의 유저를 한번에 만들 수 없기때문에 Fail 발생해야함
    // 결 과 : Pass
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
    // Race Condition 상황에서 2개의 쓰레드가 잘 작동하는지 확인하기 위한 테스트
    // 기대값 : 데드락이 걸려서 멈춰져 있거나 오류가 나면 안됨.
    // 결 과 : Pass
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
    // global queue로 어싱크로 보내면 교착상태가 걸릴 수 있음.
    // 기대값 : 쓰레드가 데이터를 요청하면서 요청받면서 멈추는 데드락이 걸리면 안됨.
    // 결 과 : Pass
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
    // 빈 넥네임을 검색할 때 오류가 발생하는지 확인하는 테스트
    // 기대값 : API를 사용하지 않고 오류를 발생시켜야함.
    // 결 과 : Pass
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
    
    // Get API를 10번이상 사용했을 때 오류가 발생하는지 확인하는 테스트
    // 기대값 : 1초에 10번 이상의 API에서는 사용하지 않고 SDK에서 오류를 발생시켜야함
    // 결 과 : Pass
    public func testRateLimitGetUser() {
        let userManager = userManagerType().init()

        // Concurrently get user info for 11 users
        let dispatchGroup = DispatchGroup()
        var results: [UserResult] = []

        for i in 0..<11 {
            dispatchGroup.enter()
            userManager.getUser(userId: "user\(i)") { result in
                results.append(result)
                dispatchGroup.leave()
            }
        }

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
    
    // 1초에 11개의 유저를 생성할 때 오류가 발생하는지 확인하는 테스트
    // 기대값 : 10개가 성공하고 1개가 실패해야함.
    // 결 과 : Error
    // 이 유 : Create User는 Post API를 사용하고 있음. 따라서 1초에 1의 API만 사용할 수 있음.
    //        따라서 성공하는 결과값이 1개 실패하는 결과값이 10개가 되어야함.
    //        아래의 testRateLimitCreateUserModify()을 사용하시길 제안합니다.
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
    
    // testRateLimitCreateUser 제안된 테스트
    public func testRateLimitCreateUserModify() {
        let userManager = userManagerType().init()
        
        // Concurrently create 11 users
        let dispatchGroup = DispatchGroup()
        var results: [UserResult] = []
        let now = Date()
        
        for i in 0..<11 {
            dispatchGroup.enter()
            userManager.createUser(params: UserCreationParams(userId: "\(now.description)_\(i)", nickname: "JohnDoe", profileURL: nil)) { result in
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

        XCTAssertEqual(successResults.count, 1)
        XCTAssertEqual(rateLimitResults.count, 10)

    }
    
    // 다수의 계정을 만드는데 POST는 1초에 1개로 제한되었는지 확인하는 테스트
    // 기대값 : 5개가 성공하고 1개가 실패해야함.
    // 결 과 : Error
    // 이 유 : Create Users는 Post API를 사용하고 있음. 따라서 1초에 1의 API만 사용할 수 있음.
    //        따라서 성공하는 결과값이 1개 실패하는 결과값이 5개가 되어야함.
    //        아래의 testRateLimitCreateUserModify()을 사용하시길 제안합니다.

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

    // 제안된 테스트
    // POST는 1초에 한번만 사용이 가능하기 때문에 성공이 1개 실패가 5개가 되어야함.
    public func testRateLimitCreateUsersModify() {
        let userManager = userManagerType().init()
        
        let now = Date()

        // Concurrently create 6 batches of users (to exceed the limit with 12 requests)
        let dispatchGroup = DispatchGroup()
        var results: [UsersResult] = []

        for i in 0..<6 {
            dispatchGroup.enter()
            let paramsArray = [UserCreationParams(userId: "JohnDoe_0_\(now.description)_\(i)", nickname: "JohnDoe", profileURL: nil),
                               UserCreationParams(userId: "JohnDoe_1_\(now.description)_\(i)", nickname: "JaneDoe", profileURL: nil)]

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

        XCTAssertEqual(successResults.count, 1) // 1 successful batch creations
        XCTAssertEqual(rateLimitResults.count, 5) // 5 rate-limited batch creation
    }
    
    // Put API를 1초에 10번이상 사용하였을 때 에러가 발생하는지 확인하는 테스트
    // 기대값 : 10개가 성공하고 1개가 실패해야함.
    // 결 과 : Pass
    // 질 문 : https://sendbird.com/docs/chat/platform-api/v3/application/understanding-rate-limits/rate-limits
    //        위의 문서를 보면 Free trial일 경우 PUT은 초당 5번 호출이 가능합니다.
    //        하지만 API에서는 10개가 성공하고 11번째에서 Too many requests가 발생하고 있는데 5번으로 제한해야 되는지 궁금했습니다.
    
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
