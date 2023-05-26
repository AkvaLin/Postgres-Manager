//
//  AddOrderViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 19.05.2023.
//

import Foundation

class AddOrderViewModel: ObservableObject {
    
    @Published var selectedClient: ClientModel
    @Published var selectedEmployee: EmployeeModel
    @Published var clients: [ClientModel]
    @Published var employees: [EmployeeModel]
    @Published var totalCost = 0.0
    @Published var ratingText = ""
    @Published var date = Date()
    @Published var services = [ServiceModel]()
    @Published var selectedServices = [ServiceModel]()

    init() {
        let client = ClientModel(id: -1, name: "None", phoneNumber: "", email: "", status: "")
        let employee = EmployeeModel(name: "None", id: -1)
        clients = [client]
        selectedClient = client
        employees = [employee]
        selectedEmployee = employee
    }
    
    private var viewModel: LoginViewModel? = nil
    
    private func getClients() async {
        await viewModel?.getAllClientsData() { [weak self] data in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.clients = data
                if !data.isEmpty {
                    strongSelf.selectedClient = strongSelf.clients[0]
                }
            }
        }
    }
    
    private func getEmployees() async {
        await viewModel?.getEmoloyeesData() { [weak self] data in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.employees = data
                if !data.isEmpty {
                    strongSelf.selectedEmployee = strongSelf.employees[0]
                }
            }
        }
    }
    
    public func getServices() async {
        await viewModel?.getAllServices { [weak self] data in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.services = data
            }
        }
    }
    
    public func setup(vm: LoginViewModel) async {
        viewModel = vm
        await getClients()
        await getEmployees()
        await getServices()
    }
    
    public func addOrder() async {
        guard let rating = Double(ratingText) else { return }
        var servicesID = [Int]()
        services.forEach { service in
            if service.add {
                servicesID.append(service.id)
            }
        }
        await viewModel?.addOrder(client: selectedClient.id, employee: selectedEmployee.id, totalCost: totalCost, rating: rating, date: date, servicesID: servicesID)
    }
    
    private func clearData() {
        services.forEach { service in
            service.add = false
        }
        if !employees.isEmpty {
            selectedEmployee = employees[0]
        }
        if !clients.isEmpty {
            selectedClient = clients[0]
        }
        totalCost = 0
        ratingText = ""
        date = Date()
    }
}
