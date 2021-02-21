//
//  PasswordModel.swift
//  iCombine
//
//  Created by Артём Мошнин on 21/2/21.
//

import Foundation

enum PasswordStatus {
    case empty
    case notStrongEnough
    case notMatchPasswords
    case valid
}

enum DescriptionStatus {
    case empty
    case tooLong
    case valid
}
