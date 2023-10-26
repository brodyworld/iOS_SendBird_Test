//
//  MoyaRouterTests.swift
//  MoyaRouterTests
//
//  Created by Brody Byun on 2023/10/21.
//

import XCTest
import Moya
@testable import SendbirdUserManager

final class MoyaRouterTests: XCTestCase {
    let provider = MoyaProvider<SendbirdRouter>(plugins: [NetworkLoggerPlugin()])
    let timeout: TimeInterval = 5

    var applicationId: String = "E30DE0C6-7F1D-4786-8A4D-795356ADC731" // default
    var apiToken: String = "f0964228b82d8b0b39497b2fe5261af0774fe4ce" // default
    
    func testCreateTenUsersOnce() {
        let expectation = self.expectation(description: "Wait for Create Users API")
        
        let params = (0..<10).map { UserCreationParams(userId: "\($0)", nickname: "User\($0)", profileURL: nil) }

        provider.request(.createUsers(params: params, apiToken: apiToken, appId: applicationId)) { result in
            
            switch result {
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))

                let decodedReponse = JSONDecoder().decodeResponse([UserEntity].self, from: response.data)
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
    
    func testCreateUserAPI() {
        let expectation = self.expectation(description: "Wait for Create User API")

        let params = UserCreationParams(userId: Date().description, nickname: "John Doe", profileURL: nil)
        
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
    
    func testCreateUsersAPI() {
        let expectation = self.expectation(description: "Wait for Create User API")

        let params = [UserCreationParams(userId: "\(Date().description)_1", nickname: "John Doe", profileURL: nil),
                      UserCreationParams(userId: "\(Date().description)_2", nickname: "John Doe", profileURL: nil)]
        
        provider.request(.createUsers(params: params, apiToken: apiToken, appId: applicationId)) { result in
            switch result {
            case .success(let response):
                print(String(data: response.data, encoding: .utf8))

                let decodedReponse = JSONDecoder().decodeResponse([UserEntity].self, from: response.data)
                
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
    
    func testGetUsersAPI() {
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
