//
//  ReportView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 25.05.2023.
//

import SwiftUI

struct ReportView: View {
    private var data: [ReportModel]
    private let isEmployee: Bool
    
    init(data: [ReportModel], isEmployee: Bool) {
        self.data = data
        self.isEmployee = isEmployee
    }
    
    var body: some View {
        VStack {
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
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(data: [ReportModel(firstColumn: "123", secondColumn: "123", thirdColumn: "123")], isEmployee: true)
    }
}
