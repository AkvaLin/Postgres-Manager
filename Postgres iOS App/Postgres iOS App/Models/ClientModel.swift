//
//  ClientModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import Foundation

struct ClientModel: Hashable {
    let id: Int
    let name: String
    let phoneNumber: String
    let email: String
    let status: String
}
