//
//  UpcomingOrdersView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 24.05.2023.
//

import SwiftUI

struct UpcomingOrdersView: View {
    
    @StateObject private var viewModel = UpcomingOrdersViewModel()
    @EnvironmentObject private var connectionVM: LoginViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.ordersData, id: \.id) { order in
                    VStack(alignment: .leading) {
                        Text("ID: \(order.id)")
                            .font(.caption2)
                            .padding(.bottom, 1)
                        Text("Employee: \(order.employeeName)")
                        Text("Client: \(order.clientName)")
                            .padding(.bottom, 1)
                        Group {
                            Text("Total cost: \(order.totalCost)")
                            Text("Rating: \(order.rating)")
                            Text("Date: \(order.date?.formatted(date: .abbreviated, time: .shortened) ?? Date().formatted(date: .abbreviated, time: .shortened))")
                        }
                        .font(.footnote)
                    }
                }
            }
            .listStyle(.inset)
            .onAppear {
                Task {
                    await viewModel.setup(vm: connectionVM)
                }
            }
            .navigationTitle("Orders")
            .refreshable {
                Task {
                    await viewModel.update()
                }
            }
        }
    }
}

struct UpcomingOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingOrdersView()
            .environmentObject(LoginViewModel())
    }
}
