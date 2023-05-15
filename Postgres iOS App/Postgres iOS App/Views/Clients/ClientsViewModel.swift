//
//  ClientsViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import Foundation

class ClientsViewModel: ObservableObject {
    
    @Published var enableDelete: Bool
    @Published var search = ""
    @Published var showingAddClientSheet = false
    
    private var viewModel: LoginViewModel? = nil
    
    public var clientsData = [
        ClientModel(id: 1, name: "Matvey", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@gmail.com", status: "default"),
        ClientModel(id: 2, name: "Egor", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@gmail.com", status: "premium"),
        ClientModel(id: 3, name: "Alex", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@gmail.com", status: "regular"),
        ClientModel(id: 4, name: "Misha", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@gmail.com", status: "default"),
        ClientModel(id: 5, name: "Crocodile", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@gmail.com", status: "default"),
        ClientModel(id: 6, name: "Car", phoneNumber: "+7(928)265-55-56", email: "123@mail.ru", status: "default"),
        ClientModel(id: 7, name: "Space", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@mail.ru", status: "default"),
        ClientModel(id: 8, name: "Whale", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@yandex.ru", status: "default"),
        ClientModel(id: 9, name: "lowercase", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@yandex.ru", status: "default"),
        ClientModel(id: 10, name: "ep", phoneNumber: "+7(928)265-55-56", email: "nikita@yandex.ru", status: "default"),
        ClientModel(id: 11, name: "as", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@yandex.ru", status: "default"),
        ClientModel(id: 12, name: "qw", phoneNumber: "+7(928)265-55-56", email: "nikita.pivovarov2003@yandex.ru", status: "default"),
    ]
    
    public var searchResults: [ClientModel] {
        if search.isEmpty {
            return clientsData
        } else {
            return clientsData.filter { model in
                model.name.lowercased().contains(search.lowercased()) ||
                model.email.lowercased().contains(search.lowercased()) ||
                String(model.id).lowercased() == search.lowercased() ||
                model.phoneNumber.lowercased().contains(search.lowercased()) ||
                model.status.lowercased().contains(search.lowercased())
            }
        }
    }
    
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
        guard let viewModel = viewModel else { return }
        clientsData = await viewModel.getAllClientsData()
    }
    
    public func delete(id: Int) async {
        guard let viewModel = viewModel else { return }
        await viewModel.deleteClientRow(id: id)
    }
    
    public func update() async {
        guard let viewModel = viewModel else { return }
        clientsData = await viewModel.getAllClientsData()
    }
    
    public func deleteWithUpdate(id: Int) async {
        await self.delete(id: id)
        await self.update()
    }
}
