//
//  OrdersView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import SwiftUI

struct OrdersView: View {
    
    @StateObject private var viewModel = OrderViewModel()
    @EnvironmentObject private var connectionVM: LoginViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                            }
                            .font(.footnote)
                        }
                    }
                    .onDelete(perform: viewModel.enableDelete ? delete : nil)
                }
                .listStyle(.inset)
                .toolbar {
                    ToolbarItemGroup {
                        Button {
                            viewModel.showingAddOrderView.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        if viewModel.enableDelete {
                            EditButton()
                        }
                    }
                }
                .onAppear {
                    viewModel.isLoading = true
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
                .navigationDestination(isPresented: $viewModel.showingAddOrderView) {
                    AddOrderView()
                }
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        Task {
            await deleteRow(at: offsets)
        }
    }
    
    private func deleteRow(at offsets: IndexSet) async {
        guard let index = offsets.first else { return }
        let id = viewModel.ordersData[index].id
        await viewModel.delete(id: id)
        viewModel.ordersData.remove(atOffsets: offsets)
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
            .environmentObject(LoginViewModel())
    }
}
