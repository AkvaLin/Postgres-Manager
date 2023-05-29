//
//  ContentView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 23.04.2023.
//

import SwiftUI

struct LoginView: View {
    
    @State var isSecured: Bool = true
    @State var showingAlert: Bool = false
    @State var alertText: String = ""
    @FocusState private var focusedLogin: Bool
    @FocusState private var focusedPassword: Bool
    
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        
        ZStack {
            VStack {
                Text("Login:")
                TextField("Enter login", text: $viewModel.login)
                    .focused($focusedLogin)
                    .padding(.bottom, 8)
                
                Text("Password:")
                AnimatedSecureTextField(text: $viewModel.password, titleKey: "Enter password")
                    .focused($focusedPassword)
                    .padding(.bottom, 8)
                
                Button("Connect", action: {
                    Task {
                        await viewModel.connect() { result in
                            switch result {
                            case .connectionError:
                                alertText = "Не удалось установить соединение с базой данных"
                                showingAlert = true
                            case .loginError:
                                alertText = "Пользователя с данным логином не существует"
                                showingAlert = true
                            case .passwordError:
                                alertText = "Неверный пароль"
                                showingAlert = true
                            case .unknownError:
                                alertText = "Неизвестная ошибка. Попробуйте позже"
                                showingAlert = true
                            case .dataError:
                                alertText = "Ошибка базы данных"
                                showingAlert = true
                            case .success:
                                DispatchQueue.main.async {
                                    viewModel.isPresented = true
                                }
                            case .queryError:
                                alertText = "Не удалось отправить запрос к базе данных"
                                showingAlert = true
                            }
                        }
                    }
                })
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.login.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                .fullScreenCover(isPresented: $viewModel.isPresented) {
                    MainView()
                        .environmentObject(viewModel)
                }
                
                Toggle("Save login data", isOn: $viewModel.isSaveEnabled)
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .tint(.primary)
                    .padding()
            }
            .blur(radius: viewModel.isLoading ? 3 : 0)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .alert(alertText, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .padding()
        .onTapGesture {
            focusedLogin = false
            focusedPassword = false
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedLogin = false
                    focusedPassword = false
                }
            }
        }
        .onSubmit {
            if focusedLogin {
                focusedLogin = false
                focusedPassword = true
            }
            if focusedPassword {
                focusedPassword = false
                Task {
                    await viewModel.connect() { result in
                        switch result {
                        case .connectionError:
                            alertText = "Не удалось установить соединение с базой данных"
                            showingAlert = true
                        case .loginError:
                            alertText = "Пользователя с данным логином не существует"
                            showingAlert = true
                        case .passwordError:
                            alertText = "Неверный пароль"
                            showingAlert = true
                        case .unknownError:
                            alertText = "Неизвестная ошибка. Попробуйте позже"
                            showingAlert = true
                        case .dataError:
                            alertText = "Ошибка базы данных"
                            showingAlert = true
                        case .success:
                            DispatchQueue.main.async {
                                viewModel.isPresented = true
                            }
                        case .queryError:
                            alertText = "Не удалось отправить запрос к базе данных"
                            showingAlert = true
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
