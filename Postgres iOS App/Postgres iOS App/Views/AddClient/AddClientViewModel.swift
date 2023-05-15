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
    
    private var viewModel: LoginViewModel? = nil
    
    public func addClient() async {
        await viewModel?.addClientRow(phoneNumber: phoneNumber, email: email, name: name)
    }
    
    public func setup(vm: LoginViewModel) async {
        viewModel = vm
    }
}
