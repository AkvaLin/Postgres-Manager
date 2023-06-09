//
//  Constants.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 14.05.2023.
//

import Foundation

enum LoginResults {
    case connectionError
    case loginError
    case passwordError
    case unknownError
    case dataError
    case success
    case queryError
}

enum AddOrderResults {
    case orderError
    case serviceError
    case success
}

enum RegisterResults {
    case loginDataError
    case employeeError
    case success
}
