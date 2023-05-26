//
//  MainView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var connectionVM: LoginViewModel
    
    var body: some View {
        TabView {
            if UserDefaults.standard.role != "administrator" {
                UpcomingOrdersView()
                    .tabItem {
                        Image(systemName: "calendar")
                    }
                OrdersView()
                    .tabItem {
                        Image(systemName: "list.bullet.clipboard")
                    }
                ClientsView()
                    .tabItem {
                        Image(systemName: "person.3")
                    }
                    .environmentObject(connectionVM)
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                    }
            } else {
                RegisterView()
                    .tabItem {
                        Image(systemName: "person")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                    }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(LoginViewModel())
    }
}
