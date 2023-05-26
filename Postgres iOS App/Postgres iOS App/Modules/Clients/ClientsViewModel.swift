//
//  ClientsViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import Foundation
import Combine

class ClientsViewModel: ObservableObject {
    
    @Published var enableDelete: Bool
    @Published var search = ""
    @Published var showingAddClientSheet = false
    
    private var viewModel: LoginViewModel? = nil
    
    @Published public var clientsData = [ClientModel]()
    
    @Published public var searchResults = [ClientModel]()
    
    private var storage: Set<AnyCancellable> = []
    
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
        setupPublisher(publisher: $search)
        $clientsData
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.searchResults = value
                    strongSelf.search = ""
                }
            }
            .store(in: &storage)
    }
    
    private func setupPublisher(publisher: Published<String>.Publisher) {
        publisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] request in
                guard let strongSelf = self else { return }
                if request.isEmpty {
                    strongSelf.searchResults = strongSelf.clientsData
                } else {
                    strongSelf.searchResults = strongSelf.clientsData.filter { model in
                        model.name.lowercased().contains(request.lowercased()) ||
                        model.email.lowercased().contains(request.lowercased()) ||
                        String(model.id).lowercased() == request.lowercased() ||
                        model.phoneNumber.lowercased().contains(request.lowercased()) ||
                        model.status.lowercased().contains(request.lowercased())
                    }
                }
            })
            .store(in: &storage)
    }
    
    public func setup(vm: LoginViewModel) async {
        viewModel = vm
        await update()
    }
    
    public func delete(id: Int) async {
        guard let viewModel = viewModel else { return }
        await viewModel.deleteClientRow(id: id)
    }
    
    public func update() async {
        guard let viewModel = viewModel else { return }
        await viewModel.getAllClientsData() { data in
            DispatchQueue.main.async { [weak self] in
                self?.clientsData = data
            }
        }
    }
    
    public func deleteWithUpdate(id: Int) async {
        await self.delete(id: id)
        await self.update()
    }
}
