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
    @Published public var selectedJob: JobModel
    @Published public var fullName = ""
    @Published public var phoneNumber = ""
    @Published public var workExperience = ""
    
    @Published public var isLoginAndPasswordEntered = false
    @Published public var isDataEntered = false
    
    private var viewModel: LoginViewModel? = nil
    
    public var roles = ["Employee", "Manager", "Administrator"]
    @Published public var jobs: [JobModel]
    private var storage: Set<AnyCancellable> = []
    
    init() {
        let job = JobModel(tile: "None", id: -1)
        jobs = [job]
        selectedJob = job
        
        setupPublisher(publisher: $login)
        setupPublisher(publisher: $password)
        setupPublisher(publisher: $secondPassword)
        setupPublisher(publisher: $age)
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
    
    public func setup(vm: LoginViewModel) async {
        viewModel = vm
        await update()
    }
    
    private func update() async {
        guard let viewModel = viewModel else { return }
        await viewModel.getJobTitleData() { data in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.jobs = data
                if !data.isEmpty {
                    strongSelf.selectedJob = strongSelf.jobs[0]
                } else {
                    strongSelf.jobs.append(JobModel(tile: "None", id: -1))
                    strongSelf.selectedJob = strongSelf.jobs[0]
                }
            }
        }
    }
    
    public func register() async {
        guard let viewModel = viewModel else { return }
        let intAge = Int(age) ?? 0
        let intExp = Int(workExperience) ?? 0
        await viewModel.register(login: login,
                                 password: password,
                                 age: intAge,
                                 name: fullName,
                                 number: phoneNumber,
                                 experience: intExp,
                                 role: selectedRole,
                                 jobTitle: selectedJob.id)
    }
}
