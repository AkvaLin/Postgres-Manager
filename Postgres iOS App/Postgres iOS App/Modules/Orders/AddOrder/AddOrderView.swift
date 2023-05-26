//
//  AddOrderView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 19.05.2023.
//

import SwiftUI
import Combine

struct AddOrderView: View {
    
    @EnvironmentObject private var connectionVM: LoginViewModel
    @ObservedObject private var viewModel = AddOrderViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Employee: ")
                    .padding()
                Spacer()
                Picker("Please select an employee", selection: $viewModel.selectedEmployee) {
                    ForEach(viewModel.employees, id: \.id) {
                        Text($0.name).tag($0)
                    }
                }
                .padding()
            }
            HStack {
                Text("Client: ")
                    .padding()
                Spacer()
                Picker("Please select a client", selection: $viewModel.selectedClient) {
                    ForEach(viewModel.clients, id: \.id) {
                        Text($0.name).tag($0)
                    }
                }
                .padding()
            }
            HStack {
                Text("Total cost: ")
                    .padding()
                Spacer()
                Text("\(viewModel.totalCost, specifier: "%.2f")")
                    .padding()
            }
            HStack {
                Text("Rating: ")
                    .padding()
                TextField("Enter rating", text: $viewModel.ratingText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .onReceive(Just(viewModel.ratingText)) { newValue in
                        var filtered = newValue.filter { "12345".contains($0) }
                        if filtered.count > 1 {
                            filtered = String(filtered.dropLast(1))
                        }
                        if filtered != newValue {
                            viewModel.ratingText = filtered
                        }
                    }
                    .padding()
            }
            DatePicker("Order date: ", selection: $viewModel.date)
                .datePickerStyle(.automatic)
                .padding()
            List {
                ForEach(viewModel.services, id: \.id) { service in
                    ZStack {
                        Color(cgColor: service.add ? CGColor(red: 0, green: 1, blue: 0, alpha: 0.3) : CGColor(red: 0, green: 0, blue: 0, alpha: 0))
                        HStack {
                            VStack(alignment: .leading) {
                                Text(service.name)
                                Text(service.cost)
                            }
                            Spacer()
                            Group {
                                Button {
                                    if service.add {
                                        viewModel.totalCost -= Double(service.cost) ?? 0
                                        service.add.toggle()
                                    }
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                                .buttonStyle(.plain)
                                Spacer()
                                Button {
                                    if !service.add {
                                        viewModel.totalCost += Double(service.cost) ?? 0
                                        service.add.toggle()
                                    }
                                } label: {
                                    Image(systemName: "plus.circle")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
            Button {
                Task {
                    await viewModel.addOrder()
                }
            } label: {
                Text("Add order")
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Add order")
        .onAppear {
            Task {
                await viewModel.setup(vm: connectionVM)
            }
        }
    }
}

struct AddOrderView_Previews: PreviewProvider {
    static var previews: some View {
        AddOrderView()
            .environmentObject(LoginViewModel())
    }
}