//
//  AddClientViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import Foundation

class AddClientViewModel: ObservableObject {
    
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var name: String = ""
    @Published var isLoading = false
    @Published var showAlert = false
    
    private var viewModel: LoginViewModel? = nil
    
    public func addClient() async {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        await viewModel?.addClientRow(phoneNumber: phoneNumber, email: email, name: name) { [weak self] success in
            guard let strongSelf = self else { return }
            strongSelf.clearData()
            DispatchQueue.main.async {
                strongSelf.isLoading = false
                if !success {
                    strongSelf.showAlert = true
                }
            }
        }
    }
    
    public func setup(vm: LoginViewModel) async {
        viewModel = vm
    }
    
    private func clearData() {
        phoneNumber = ""
        email = ""
        name = ""
    }
}
