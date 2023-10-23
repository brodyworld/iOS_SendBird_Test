//
//  RouterTests.swift
//  ApiTests
//
//  Created by Brody Byun on 2023/10/21.
//

import XCTest
import Moya
@testable import SendbirdUserManager

final class ApiTests: XCTestCase {
    let provider = MoyaProvider<SendbirdRouter>(plugins: [NetworkLoggerPlugin()])
    let timeout: TimeInterval = 5

    var applicationId: String = "E30DE0C6-7F1D-4786-8A4D-795356ADC731" // default
    var apiToken: String = "f0964228b82d8b0b39497b2fe5261af0774fe4ce" // default

    func testsCustom() {
        let userManager = UserManagerImplement()
//        let expectation = self.expectation(description: "Wait for Create User API")
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()

        userManager.getUser(userId: "1") { result in
            
            switch result {
            case .success(let response): break
//                XCTAssertNotNil(response)
            case .failure(let error): break
//                XCTFail(error.localizedDescription)
            }
//            expectation.fulfill()
            dispatchGroup.leave()

        }
        
        let a = dispatchGroup.wait(timeout: .now() + 5.0)
//        waitForExpectations(timeout: timeout)

        print("AAAA")
    }
    
    func testsCreateUserAPI() {
        let expectation = self.expectation(description: "Wait for Create User API")

        let params = UserCreationParams(userId: Date().description, nickname: "John Doe", profileURL: nil)
//        let params = UserCreationParams(userId: "4000", nickname: "John Doe", profileURL: nil)

        provider.request(.createUser(params: params, apiToken: self.apiToken, appId: self.applicationId)) { result in
            
            switch result {
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))

                let decodedReponse = JSONDecoder().decodeResponse(UserEntity.self, from: response.data)
                
                switch decodedReponse {
                case .success(let success):
                    XCTAssertNotNil(success)
                    expectation.fulfill()
                case .failure(let failure):
                    XCTFail(failure.localizedDescription)
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func testGetUserAPI() {
        let expectation = self.expectation(description: "Wait for Read User API")
            
        provider.request(.getUser(userId: "1", apiToken: self.apiToken, appId: self.applicationId)) { result in
            switch result {
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))

                let decodedReponse = JSONDecoder().decodeResponse(UserEntity.self, from: response.data)
                switch decodedReponse {
                case .success(let success):
                    XCTAssertNotNil(success)
                    expectation.fulfill()
                case .failure(let failure):
                    XCTFail(failure.localizedDescription)
                }

                
            case .failure(let error):
                XCTFail(error.localizedDescription)

            }
        }
        waitForExpectations(timeout: timeout)
    }
    
    func testUpdateUserAPI() {
        let expectation = self.expectation(description: "Wait for Update User API")

        let params = UserUpdateParams(userId: "1", nickname: Date().description, profileURL: nil)

        provider.request(.updateUser(params: params, apiToken: self.apiToken, appId: self.applicationId)) { result in
            
            switch result {
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))

                let decodedReponse = JSONDecoder().decodeResponse(UserEntity.self, from: response.data)
                
                switch decodedReponse {
                case .success(let success):
                    XCTAssertNotNil(success)
                    expectation.fulfill()
                case .failure(let failure):
                    XCTFail(failure.localizedDescription)
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func testsGetUsersAPI() {
        let expectation = self.expectation(description: "Wait for Read User List API")
            
        provider.request(.getUsers(nickname: "John Doe", apiToken: self.apiToken, appId: self.applicationId)) { result in
            switch result {
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))

                let decodedReponse = JSONDecoder().decodeResponse(UserListEntity.self, from: response.data)
                switch decodedReponse {
                case .success(let success):
                    XCTAssertNotNil(success)
                    expectation.fulfill()
                case .failure(let failure):
                    XCTFail(failure.localizedDescription)
                }

                
            case .failure(let error):
                XCTFail(error.localizedDescription)

            }
        }
        waitForExpectations(timeout: timeout)
    }
    
}
