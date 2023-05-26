//
//  OrderModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import Foundation

struct OrderModel {
    let id: Int
    let totalCost: String
    let rating: String
    let clientName: String
    let employeeName: String
    var date: Date? = nil
}
