//
//  OrederViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import Foundation

class OrderViewModel: ObservableObject {
    
    @Published var enableDelete: Bool
    @Published var showingAddOrderView = false
    
    private var viewModel: LoginViewModel? = nil
    
    @Published public var ordersData = [OrderModel]()
    
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
        await update()
    }
    
    public func update() async {
        await viewModel?.getAllOrdersData { [weak self] data in
            DispatchQueue.main.async { [weak self] in
                self?.ordersData = data
            }
        }
    }
    
    public func delete(id: Int) async {
        guard let viewModel = viewModel else { return }
        await viewModel.deleteOrderRow(id: id)
    }
}
