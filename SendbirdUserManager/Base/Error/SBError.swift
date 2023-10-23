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
