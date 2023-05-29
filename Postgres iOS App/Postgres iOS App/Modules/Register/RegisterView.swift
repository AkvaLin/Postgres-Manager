//
//  RegisterView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 10.05.2023.
//

import SwiftUI
import Combine

struct RegisterView: View {
    enum RegisterField {
        case login
        case password
        case secondPassword
        case age
        case name
        case phoneNumber
        case work
    }
    
    @EnvironmentObject private var connectionVM: LoginViewModel
    @ObservedObject private var viewModel = RegisterViewModel()
    
    @State private var showGroup = false
    @State private var isRegisterButtonDisabled = true
    @FocusState private var focusedField: RegisterField?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TextField("Login", text: $viewModel.login)
                        .focused($focusedField, equals: .login)
                        .padding(.horizontal)
                    AnimatedSecureTextField(text: $viewModel.password, titleKey: "Password")
                        .focused($focusedField, equals: .password)
                        .padding(.horizontal)
                    AnimatedSecureTextField(text: $viewModel.secondPassword, titleKey: "Confirm password")
                        .focused($focusedField, equals: .secondPassword)
                        .padding([.horizontal, .bottom])
                    
                    if showGroup
                    {
                        TextField("Age", text: $viewModel.age)
                            .focused($focusedField, equals: .age)
                            .keyboardType(.numberPad)
                            .onReceive(Just(viewModel.age)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    viewModel.age = filtered
                                }
                            }
                            .padding([.leading, .trailing])
                        TextField("Full name", text: $viewModel.fullName)
                            .focused($focusedField, equals: .name)
                            .padding([.leading, .trailing])
                        TextField("Phone number", text: $viewModel.phoneNumber)
                            .focused($focusedField, equals: .phoneNumber)
                            .keyboardType(.phonePad)
                            .padding([.leading, .trailing])
                        TextField("Work experience", text: $viewModel.workExperience)
                            .focused($focusedField, equals: .work)
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
                .blur(radius: viewModel.isLoading ? 3 : 0)
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        Task {
                            await viewModel.update()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusedField = .none
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.setup(vm: connectionVM)
                }
            }
            .alert("Failed to add login data", isPresented: $viewModel.showLoginDataError) {
                Button("OK", role: .cancel) { }
            }
            .alert("The login data has been added\nFailed to add employee", isPresented: $viewModel.showEmployeeError) {
                Button("OK", role: .cancel) { }
            }
            .onSubmit {
                switch focusedField {
                case .login:
                    focusedField = .password
                case .password:
                    focusedField = .secondPassword
                case .secondPassword:
                    focusedField = .age
                case .age:
                    focusedField = .name
                case .name:
                    focusedField = .phoneNumber
                case .phoneNumber:
                    focusedField = .work
                case .work:
                    focusedField = .none
                case .none:
                    break
                }
            }
            .onTapGesture {
                focusedField = .none
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
