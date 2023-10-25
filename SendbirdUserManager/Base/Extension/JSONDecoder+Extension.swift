//
//  JSONDecoder+Extension.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

extension JSONDecoder {
    func decodeResponse<T: Codable>(_ type: T.Type, from data: Data)  -> Result<T, Error> {
        do {
            if let response = try? decode(T.self, from: data) {
                return .success(response)
            } else {
                let apiErrorResponse = try decode(APIError.self, from: data)
                return .failure(APIError(message: apiErrorResponse.message ,
                                         code: apiErrorResponse.code,
                                         error: apiErrorResponse.error))
            }
        } catch let error {
            return .failure(error)
        }
    }
    
    
}
