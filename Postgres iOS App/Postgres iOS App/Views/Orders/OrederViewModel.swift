//
//  OrederViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import Foundation

class OrderViewModel: ObservableObject {
    
    @Published var enableDelete: Bool
    @Published var showingAddClientSheet = false
    
    private var viewModel: LoginViewModel? = nil
    
    public var ordersData = [
        OrderModel(id: 1, totalCost: 10, rating: 1, clientName: "Short name", employeeName: "Short name"),
        OrderModel(id: 2, totalCost: 20, rating: 2, clientName: "Very looooooooooooooooooooong name", employeeName: "Very looooooooooooooooooooong name"),
        OrderModel(id: 3, totalCost: 30, rating: 3, clientName: "FirstName LastName", employeeName: "FirstName LastName"),
        OrderModel(id: 4, totalCost: 40, rating: 4, clientName: "FirstName LastName AnotherName", employeeName: "FirstName LastName AnotherName"),
        OrderModel(id: 5, totalCost: 120000, rating: 5, clientName: "", employeeName: ""),
        OrderModel(id: 6, totalCost: 1593, rating: 2, clientName: "as", employeeName: "as")
    ]
    
    init() {
        if let role = UserDefaults.standard.role {
            if role == "manager" {
                enableDelete = true
            } else {
                enableDelete = false
            }
        } else {
            enableDelete = false
        }
    }
    
    public func setup(vm: LoginViewModel) async {
        viewModel = vm
    }
}
