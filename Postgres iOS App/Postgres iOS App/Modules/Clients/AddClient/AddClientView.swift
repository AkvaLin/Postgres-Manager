//
//  AddClientView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import SwiftUI

struct AddClientView: View {
    
    @StateObject private var viewModel = AddClientViewModel()
    @EnvironmentObject private var connectionVM: LoginViewModel
    
    var body: some View {
        VStack {
            Group {
                TextField("Enter name", text: $viewModel.name)
                TextField("Enter email", text: $viewModel.email)
                TextField("Enter phone number", text: $viewModel.phoneNumber)
                Button("Add client", action: {
                    Task {
                        await viewModel.addClient()
                    }
                })
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.email.isEmpty || viewModel.name.isEmpty || viewModel.phoneNumber.isEmpty)
            }
            .textFieldStyle(.roundedBorder)
            .padding()
        }
        .onAppear {
            Task {
                await viewModel.setup(vm: connectionVM)
            }
        }
        .navigationTitle("Add Client")
    }
}

struct AddClientView_Previews: PreviewProvider {
    static var previews: some View {
        AddClientView()
            .environmentObject(LoginViewModel())
    }
}
