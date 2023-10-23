//
//  MoyaProvider+Extension.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation
import Moya

extension MoyaProvider {
    func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: Moya.ProgressBlock? = .none ) async -> Result<Response, MoyaError> {
        return await withCheckedContinuation { continuation in
            self.request(target, callbackQueue: callbackQueue, progress: progress) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

