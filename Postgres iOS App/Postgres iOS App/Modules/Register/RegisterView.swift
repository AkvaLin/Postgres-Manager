//
//  RegisterView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 10.05.2023.
//

import SwiftUI
import Combine

struct RegisterView: View {
    
    @EnvironmentObject private var connectionVM: LoginViewModel
    @ObservedObject private var viewModel = RegisterViewModel()
    
    @State private var showGroup = false
    @State private var isRegisterButtonDisabled = true
    
    var body: some View {
        
        VStack {
            
            TextField("Login", text: $viewModel.login)
                .padding(.horizontal)
            AnimatedSecureTextField(text: $viewModel.password, titleKey: "Password")
                .padding(.horizontal)
            AnimatedSecureTextField(text: $viewModel.secondPassword, titleKey: "Confirm password")
                .padding([.horizontal, .bottom])
            
            if showGroup
            {
                TextField("Age", text: $viewModel.age)
                    .keyboardType(.numberPad)
                    .onReceive(Just(viewModel.age)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            viewModel.age = filtered
                        }
                    }
                    .padding([.leading, .trailing])
                TextField("Full name", text: $viewModel.fullName)
                    .padding([.leading, .trailing])
                TextField("Phone number", text: $viewModel.phoneNumber)
                    .padding([.leading, .trailing])
                TextField("Work experience", text: $viewModel.workExperience)
                    .keyboardType(.numberPad)
                    .onReceive(Just(viewModel.workExperience)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            viewModel.workExperience = filtered
                        }
                    }
                    .padding([.leading, .trailing])
            }
            
            Picker("Please choose a role", selection: $viewModel.selectedRole) {
                ForEach(viewModel.roles, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding([.leading, .trailing, .top])
            
            Picker("Please choose a job title", selection: $viewModel.selectedJob) {
                ForEach(viewModel.jobs, id: \.id) {
                    Text($0.tile).tag($0)
                }
            }
            
            Button {
                Task {
                    await viewModel.register()
                }
            } label: {
                Text("Register")
            }
            .disabled(isRegisterButtonDisabled)
            .padding()
        }
        .textFieldStyle(.roundedBorder)
        .onChange(of: viewModel.isLoginAndPasswordEntered) { newValue in
            withAnimation {
                showGroup = newValue
            }
        }
        .onChange(of: viewModel.isDataEntered) { newValue in
            withAnimation {
                isRegisterButtonDisabled = !newValue
            }
        }
        .onAppear {
            Task {
                await viewModel.setup(vm: connectionVM)
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(LoginViewModel())
    }
}
