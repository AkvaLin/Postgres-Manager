//
//  SettingsViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 24.05.2023.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    @Published var showingPopover = false
    @Published var employees = false
    @Published var general = false
    @Published var from = Date()
    @Published var to = Date()
    @Published var isReportViewPresented = false
    
    public var reportData = [ReportModel]()
    public var isEmployee = false
    
    private var viewModel: LoginViewModel? = nil
    
    
    public func setup(vm: LoginViewModel) {
        viewModel = vm
    }
    
    public func getEmployeeReport() async {
        await viewModel?.getEmployeeReport(from: dateToString(date: from), to: dateToString(date: to)) { [weak self] data in
            self?.reportData = data
            DispatchQueue.main.async { [weak self] in
                self?.showingPopover = false
                self?.isEmployee = true
                self?.isReportViewPresented = true
            }
        }
    }
    
    public func getGeneralReport() async {
        await viewModel?.getGeneralReport(from: dateToString(date: from), to: dateToString(date: to)) { [weak self] data in
            self?.reportData = data
            DispatchQueue.main.async { [weak self] in
                self?.showingPopover = false
                self?.isEmployee = false
                self?.isReportViewPresented = true
            }
        }
    }
    
    public func exit() async {
        await viewModel?.exit()
        DispatchQueue.main.async {
            self.viewModel?.isPresented = false
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
