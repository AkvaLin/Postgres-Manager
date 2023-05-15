//
//  ContentView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 23.04.2023.
//

import SwiftUI

struct LoginView: View {
    
    @State var login: String
    @State var password: String
    @State var isSecured: Bool = true
    @State var showingAlert: Bool = false
    @State var alertText: String = ""
    
    @StateObject private var viewModel = LoginViewModel()
    
    init() {
        if let login = UserDefaults.standard.login {
            self.login = login
        } else {
            self.login = ""
        }
        if let password = UserDefaults.standard.password {
            self.password = password
        } else {
            self.password = ""
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Login:")
                TextField("Enter login", text: $login)
                    .padding(.bottom, 8)
                
                Text("Password:")
                AnimatedSecureTextField(text: $password, titleKey: "Enter password")
                .padding(.bottom, 8)
                
                Button("Connect", action: {
                    Task {
                        await viewModel.connect(login: login, password: password) { result in
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
                                break
                            case .queryError:
                                alertText = "Не удалось отправить запрос к базе данных"
                                showingAlert = true
                            }
                        }
                    }
                })
                .buttonStyle(.borderedProminent)
                .disabled(login.isEmpty || password.isEmpty)
                Toggle("Save login data", isOn: $viewModel.isSaveEnabled)
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .tint(.primary)
                    .padding()
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            .alert(alertText, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
