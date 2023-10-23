//
//  SBError.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

enum SBError: Error {
    case userListNicknameEmptyError
    case createUserMoreThan10OnceError
}

extension SBError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userListNicknameEmptyError:
            return "nickname이 비어져 있습니다."
        case .createUserMoreThan10OnceError:
            return "한번에 10개 이상의 유저를 만들 수 없습니다."
        }
    }
}
