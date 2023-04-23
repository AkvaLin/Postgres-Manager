//
//  ContentView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 23.04.2023.
//

import SwiftUI

struct LoginView: View {
    
    @State var login: String = ""
    @State var password: String = ""
    @State var isSecured: Bool = true
    
    private let viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            Text("Login:")
            TextField("Enter login", text: $login)
                .padding(.bottom, 8)
            
            Text("Password:")
            ZStack(alignment: .trailing) {
                Group {
                    if isSecured {
                        SecureField("Enter password", text: $password)
                    } else {
                        TextField("Enter password", text: $password)
                    }
                }
                .padding(.trailing, 32)
                
                Button {
                    isSecured.toggle()
                } label: {
                    Image(systemName: self.isSecured ? "eye.slash" : "eye")
                        .accentColor(.gray)
                }
            }
            .padding(.bottom, 8)
            
            Button("Connect", action: {
                Task {
                    await viewModel.connect(login: login, password: password)
                }
            })
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .textFieldStyle(.roundedBorder)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
