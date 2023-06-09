//
//  ClientsView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 15.05.2023.
//

import SwiftUI

struct ClientsView: View {
    
    @EnvironmentObject private var connectionVM: LoginViewModel
    @StateObject private var viewModel = ClientsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(viewModel.searchResults, id: \.id) { client in
                        VStack(alignment: .leading) {
                            Text(client.name)
                                .padding(.bottom, 1)
                            Group {
                                Text(client.email)
                                Text(client.phoneNumber)
                            }
                            .font(.footnote)
                            HStack {
                                Text("ID: \(client.id)")
                                Text("Status: \(client.status)")
                            }
                            .font(.caption2)
                            .padding(.top, 1)
                        }
                    }
                    .onDelete(perform: viewModel.enableDelete ? delete : nil)
                }
                .toolbar {
                    ToolbarItemGroup {
                        Button {
                            viewModel.showingAddClientSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        if viewModel.enableDelete {
                            EditButton()
                        }
                    }
                }
                .searchable(text: $viewModel.search)
                .onAppear {
                    viewModel.isLoading = true
                    Task {
                        await viewModel.setup(vm: connectionVM)
                    }
                }
                .navigationDestination(isPresented: $viewModel.showingAddClientSheet) {
                    AddClientView()
                }
                .listStyle(.inset)
                .refreshable {
                    Task {
                        await viewModel.update()
                    }
                }
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Clients")
        }
    }
    
    private func delete(at offsets: IndexSet) {
        Task {
            await deleteRow(at: offsets)
        }
    }
    
    private func deleteRow(at offsets: IndexSet) async {
        if viewModel.search.isEmpty {
            guard let index = offsets.first else { return }
            let id = viewModel.clientsData[index].id
            await viewModel.delete(id: id)
            viewModel.clientsData.remove(atOffsets: offsets)
        } else {
            guard let index = offsets.first else { return }
            let id = viewModel.searchResults[index].id
            await viewModel.deleteWithUpdate(id: id)
        }
    }
}

struct ClientsView_Previews: PreviewProvider {
    static var previews: some View {
        ClientsView()
            .environmentObject(LoginViewModel())
    }
}
