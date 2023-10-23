//
//  APIError.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

struct APIError: Error, Codable {
    let message: String
    let code: Int
    let error: Bool
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        return "Code : \(code) Message : \(message)"
    }
}
