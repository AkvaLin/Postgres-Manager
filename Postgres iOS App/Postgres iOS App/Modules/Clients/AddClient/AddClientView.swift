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
        ZStack {
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
                    .disabled(viewModel.email.isEmpty ||
                              viewModel.name.isEmpty ||
                              viewModel.phoneNumber.isEmpty ||
                              viewModel.isLoading)
                }
                .textFieldStyle(.roundedBorder)
                .padding()
            }
            .blur(radius: viewModel.isLoading ? 3 : 0)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                await viewModel.setup(vm: connectionVM)
            }
        }
        .alert("Failed to add client", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
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
