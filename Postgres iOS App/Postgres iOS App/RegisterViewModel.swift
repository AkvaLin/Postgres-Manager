//
//  RegisterViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 10.05.2023.
//

import Foundation
import Combine
import SwiftUI

class RegisterViewModel: ObservableObject {
    
    @Published public var selectedRole = "Manager"
    @Published public var login = ""
    @Published public var password = ""
    @Published public var secondPassword = ""
    @Published public var age = ""
    @Published public var selectedJob = "None"
    @Published public var fullName = ""
    @Published public var phoneNumber = ""
    @Published public var workExperience = ""
    
    @Published public var isLoginAndPasswordEntered = false
    @Published public var isDataEntered = false
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    public var roles = ["Employee", "Manager", "Adminisrator"]
    public var jobs = ["None"]
    private var storage: Set<AnyCancellable> = []
    
    init() {
        setupPublisher(publisher: $login)
        setupPublisher(publisher: $password)
        setupPublisher(publisher: $secondPassword)
        setupPublisher(publisher: $age)
        setupPublisher(publisher: $selectedJob)
        setupPublisher(publisher: $fullName)
        setupPublisher(publisher: $phoneNumber)
        setupPublisher(publisher: $workExperience)
    }
    
    private func setupPublisher(publisher: Published<String>.Publisher) {
        publisher
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] _ in
                self?.checkAllData()
            })
            .store(in: &storage)
    }
    
    private func checkLoginAndPasswords() {
        if !login.isEmpty,
           !password.isEmpty,
           password == secondPassword {
            withAnimation {
                isLoginAndPasswordEntered = true
            }
        } else {
            withAnimation {
                isLoginAndPasswordEntered = false
            }
        }
    }
    
    private func checkAllData() {
        checkLoginAndPasswords()
        
        if isLoginAndPasswordEntered,
           !age.isEmpty,
           !fullName.isEmpty,
           !phoneNumber.isEmpty,
           !workExperience.isEmpty {
            withAnimation {
                isDataEntered = true
            }
        } else {
            withAnimation {
                isDataEntered = false
            }
        }
    }
}
