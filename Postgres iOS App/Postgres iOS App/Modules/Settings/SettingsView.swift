//
//  SettingsView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 24.05.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var connectionVM: LoginViewModel
    @ObservedObject var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                HStack {
                    Button {
                        viewModel.employees = true
                        viewModel.showingPopover = true
                    } label: {
                        HStack {
                            Image(systemName: "person.3")
                            Text("Employee Report")
                        }
                    }
                    Button {
                        viewModel.general = true
                        viewModel.showingPopover = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.plaintext")
                            Text("General report on profitability")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                Spacer()
                    .fullScreenCover(isPresented: $viewModel.isReportViewPresented) {
                        ReportView(data: viewModel.reportData, isEmployee: viewModel.isEmployee)
                            .environmentObject(viewModel)
                    }
                    .popover(isPresented: $viewModel.showingPopover) {
                        ZStack {
                            VStack(alignment: .leading) {
                                Text("Please, specify the time period for the report")
                                    .font(.title)
                                    .padding()
                                HStack {
                                    DatePicker("From: ", selection: $viewModel.from,  displayedComponents: .date)
                                }
                                .padding()
                                HStack {
                                    DatePicker("To: ", selection: $viewModel.to, displayedComponents: .date)
                                }
                                .padding()
                                HStack {
                                    Spacer()
                                    Button {
                                        if viewModel.employees {
                                            Task {
                                                await viewModel.getEmployeeReport()
                                            }
                                        }
                                        if viewModel.general {
                                            Task {
                                                await viewModel.getGeneralReport()
                                            }
                                        }
                                    } label: {
                                        Text("Get report")
                                    }
                                    .padding()
                                    .buttonStyle(.borderedProminent)
                                    .disabled(viewModel.isLoading)
                                    Spacer()
                                }
                            }
                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                        .padding()
                        .onDisappear {
                            viewModel.employees = false
                            viewModel.general = false
                        }
                    }
                Button {
                    Task {
                        await viewModel.exit()
                    }
                } label: {
                    HStack {
                        Image(systemName: "door.left.hand.open")
                        Text("Log out")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Settings")
        }
        .onAppear {
            viewModel.setup(vm: connectionVM)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LoginViewModel())
    }
}
