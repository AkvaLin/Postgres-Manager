//
//  ReportModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 25.05.2023.
//

import Foundation

struct ReportModel: Identifiable {
    let firstColumn: String
    let secondColumn: String
    let thirdColumn: String
    let id = UUID()
}
