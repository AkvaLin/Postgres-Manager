//
//  UpcomingOrdersViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 24.05.2023.
//

import Foundation

class UpcomingOrdersViewModel: ObservableObject {
    
    @Published var ordersData = [OrderModel]()
    
    private var viewModel: LoginViewModel? = nil
    
    public func setup(vm: LoginViewModel) async {
        viewModel = vm
        await update()
    }
    
    public func update() async {
        await viewModel?.getUpcomingOrders() { [weak self] data in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.ordersData = data.sorted(by: { first, second in
                    first.date ?? Date() <= second.date ?? Date()
                })
            }
        }
    }
}
