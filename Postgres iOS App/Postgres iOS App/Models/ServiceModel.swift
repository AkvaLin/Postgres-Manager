//
//  ServiceModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 19.05.2023.
//

import Foundation

class ServiceModel {
    let name: String
    let cost: String
    let id: Int
    var add: Bool = false
    
    init(name: String, cost: String, id: Int) {
        self.name = name
        self.cost = cost
        self.id = id
    }
}
