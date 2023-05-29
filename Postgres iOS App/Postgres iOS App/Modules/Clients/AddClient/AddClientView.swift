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
    
    @FocusState private var focusedName: Bool
    @FocusState private var focusedEmail: Bool
    @FocusState private var focusedPhone: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Group {
                    TextField("Enter name", text: $viewModel.name)
                        .focused($focusedName)
                    TextField("Enter email", text: $viewModel.email)
                        .focused($focusedEmail)
                        .keyboardType(.emailAddress)
                    TextField("Enter phone number", text: $viewModel.phoneNumber)
                        .focused($focusedPhone)
                        .keyboardType(.phonePad)
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
        .onSubmit {
            if focusedName {
                focusedName = false
                focusedEmail = true
            }
            if focusedEmail {
                focusedEmail = false
                focusedPhone = true
            }
            if focusedPhone {
                focusedPhone = false
            }
        }
        .onTapGesture {
            focusedName = false
            focusedEmail = false
            focusedPhone = false
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedName = false
                    focusedEmail = false
                    focusedPhone = false
                }
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
