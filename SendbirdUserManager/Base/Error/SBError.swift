//
//  SBError.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation

enum SBError: Error {
    case userListNicknameEmptyError
    case postRateLimitError
    case getRateLimitError
    case createUserMoreThan10OnceError
    case maximumUserIdLengthError
    case maximumNicknameLengthError
    case maximumProfileUrlLengthError
}

extension SBError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userListNicknameEmptyError:
            return "nickname이 비어져 있습니다."
        case .createUserMoreThan10OnceError:
            return "한번에 10개 이상의 유저를 만들 수 없습니다."
        case .postRateLimitError:
            return "POST API는 1초에 1번이하로 요청되어야 합니다."
        case .getRateLimitError:
            return "GET API는 1초에 10번이하로 요청되어야 합니다."
        case .maximumUserIdLengthError:
            return "User Id는 80글자 이하여야 합니다."
        case .maximumNicknameLengthError:
            return "User의 nickname은 80글자 이하여야 합니다."
        case .maximumProfileUrlLengthError:
            return "User의 profile_url은 2048글자 이하여야 합니다."
        }
    }
}
