//
//  UserDefaultsExtension.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 14.05.2023.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case login
        case password
        case role
    }
    
    var login: String? {
        get {
            string(forKey: UserDefaultsKeys.login.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.login.rawValue)
        }
    }
    
    var password: String? {
        get {
            string(forKey: UserDefaultsKeys.password.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.password.rawValue)
        }
    }
    
    var role: String? {
        get {
            string(forKey: UserDefaultsKeys.role.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.role.rawValue)
        }
    }
}
