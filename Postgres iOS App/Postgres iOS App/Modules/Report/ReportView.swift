//
//  ReportView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 25.05.2023.
//

import SwiftUI

struct ReportView: View {
#if os(iOS)
    private let isIOS = true
#else
    private let isIOS = false
#endif
    
    @EnvironmentObject var vm: SettingsViewModel
    
    private var data: [ReportModel]
    private let isEmployee: Bool
    
    init(data: [ReportModel], isEmployee: Bool) {
        self.data = data
        self.isEmployee = isEmployee
    }
    
    var body: some View {
        
        VStack {
            if isIOS {
                List {
                    Grid {
                        GridRow {
                            Text(isEmployee ? "Name" : "Service")
                            Text(isEmployee ? "Phone number" : "Count")
                            Text(isEmployee ? "Rating" : "Total Cost")
                        }
                        .bold()
                        Divider()
                        ForEach(data) { datum in
                            GridRow {
                                Text(datum.firstColumn)
                                Text(datum.secondColumn)
                                Text(datum.thirdColumn)
                            }
                            if datum.id != data.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            } else {
                Table(data) {
                    TableColumn(isEmployee ? "Name" : "Service", value: \.firstColumn)
                    TableColumn(isEmployee ? "Phone number" : "Count", value: \.secondColumn)
                    TableColumn(isEmployee ? "Rating" : "Total Cost", value: \.thirdColumn)
                }
            }
            Button {
                vm.isReportViewPresented = false
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .padding()
                    Text("Return")
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(data: [ReportModel(firstColumn: "123", secondColumn: "123", thirdColumn: "123")], isEmployee: true)
    }
}
