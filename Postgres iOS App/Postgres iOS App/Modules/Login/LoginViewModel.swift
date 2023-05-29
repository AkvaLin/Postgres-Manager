//
//  LoginViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 23.04.2023.
//

import Foundation
import PostgresKit

class LoginViewModel: ObservableObject {
    
    @Published var isSaveEnabled: Bool = false
    @Published var isPresented = false
    @Published var login: String
    @Published var password: String
    @Published var isLoading = false
    
    // Database settings
    private let host = "db.tjytbokwkceokguvmtrh.supabase.co"
    private let database = "postgres"
    private let loginDB = "postgres"
    private let passwordDB = "xyhwu2-nesded-poWqad"
    
    private var eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    private let logger = Logger(label: "postgres-logger")
    private var connection: PostgresConnection? = nil
    
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
        setEventLoopGroup()
    }
    
    public func connect(completion: @escaping (LoginResults) -> Void) async {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        do {
            try await connection?.close()
        } catch let error {
            print("cannot close connection: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            completion(.unknownError)
        }
        
        guard let eventLoopGroup = eventLoopGroup else {
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            return
        }
        
        let configuration = PostgresConnection.Configuration(
            host: host,
            username: self.loginDB,
            password: self.passwordDB,
            database: database,
            tls: .disable
        )
        
        do {
            connection = try await PostgresConnection.connect(on: eventLoopGroup.next(), configuration: configuration, id: 1, logger: logger)
        } catch let error {
            print("error: \(error)")
            completion(.connectionError)
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            return
        }
        
        do {
            let checkPassword = try await connection?.query("SELECT check_password(\(login), \(password))", logger: logger)
            guard let checkPassword = checkPassword else {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
                completion(.dataError)
                return
            }
            do {
                for try await result in checkPassword.decode((Bool).self) {
                    if result {
                        let rows = try await connection?.query("SELECT * FROM login_data WHERE login = \(login)", logger: logger)
                        guard let rows = rows else {
                            DispatchQueue.main.async { [weak self] in
                                self?.isLoading = false
                            }
                            completion(.dataError)
                            return
                        }
                        for try await row in rows {
                            let roleCell = row.first { cell in
                                cell.columnName == "role"
                            }
                            guard let roleCell = roleCell else {
                                DispatchQueue.main.async { [weak self] in
                                    self?.isLoading = false
                                }
                                completion(.dataError)
                                return
                            }
                            let role = try roleCell.decode((String).self)
                            print("Login succed with role \(role)")
                            do {
                                let query = PostgresQuery(unicodeScalarLiteral: "SET ROLE \(login)")
                                try await connection?.query(query, logger: logger)
                                UserDefaults.standard.role = role
                                if isSaveEnabled {
                                    UserDefaults.standard.login = login
                                    UserDefaults.standard.password = password
                                } else {
                                    UserDefaults.standard.login = nil
                                    UserDefaults.standard.password = nil
                                }
                                DispatchQueue.main.async { [weak self] in
                                    self?.isLoading = false
                                }
                                completion(.success)
                            } catch let error {
                                print("Role didnt change: \(error)")
                                DispatchQueue.main.async { [weak self] in
                                    self?.isLoading = false
                                }
                                clearData()
                                completion(.connectionError)
                            }
                        }
                    } else {
                        print("Wrong password")
                        DispatchQueue.main.async { [weak self] in
                            self?.isLoading = false
                        }
                        clearData()
                        completion(.passwordError)
                        return
                    }
                }
            } catch {
                print("User doesnt exist")
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
                clearData()
                completion(.loginError)
                return
            }
        } catch let error {
            print("query error: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            clearData()
            completion(.queryError)
            return
        }
    }
    
    public func getAllOrdersData(clouser: @escaping ([OrderModel]) -> Void) async {
        do {
            let ordersData = try await connection?.query("select order_id, cast(total_cost as varchar), cast(orders.rating as varchar), client.name as client, employee.name as employee from orders join client using (client_id) join employee using (employee_id)", logger: logger)
            guard let ordersData = ordersData else { clouser([OrderModel]()); return }
            var orders = [OrderModel]()
            for try await (id, totalCost, rating, client, employee) in ordersData.decode((Int, String, String, String, String).self) {
                orders.append(OrderModel(id: id, totalCost: totalCost, rating: rating, clientName: client, employeeName: employee))
            }
            clouser(orders)
        } catch let error {
            print("Get all orders data error: \(error.localizedDescription)")
            clouser([OrderModel]())
        }
    }
    
    public func deleteOrderRow(id: Int) async {
        do {
            let query = PostgresQuery(unicodeScalarLiteral: "CALL delete_order(\(id))")
            try await connection?.query(query, logger: logger)
        } catch let error {
            print("Delete order error: \(error.localizedDescription)")
        }
    }
    
    public func getAllClientsData(clouser: @escaping ([ClientModel]) -> Void) async {
        do {
            let clientsData = try await connection?.query("select * from client join client_status using (client_status_id)", logger: logger)
            guard let clientsData = clientsData else { clouser([ClientModel]()); return }
            var clients = [ClientModel]()
            for try await (_, client_id, phone_number, email, name, title, _) in clientsData.decode((Int, Int, String, String, String, String, Int).self) {
                clients.append(ClientModel(id: client_id, name: name, phoneNumber: phone_number, email: email, status: title))
            }
            clouser(clients)
        } catch let error {
            print("Get all clients data error: \(error)")
            clouser([ClientModel]())
        }
    }
    
    public func deleteClientRow(id: Int) async {
        do {
            let query = PostgresQuery(unicodeScalarLiteral: "CALL delete_client(\(id))")
            try await connection?.query(query, logger: logger)
        } catch let error {
            print("Delete client error: \(error.localizedDescription)")
        }
    }
    
    public func addClientRow(phoneNumber: String, email: String, name: String, clouser: @escaping (Bool) -> Void) async {
        do {
            let status = 1
            let query = PostgresQuery(unicodeScalarLiteral: "insert into client (phone_number, email, client_status_id, name) VALUES ('\(phoneNumber)', '\(email)', \(status), '\(name)')")
            try await connection?.query(query, logger: logger)
            clouser(true)
        } catch let error {
            print("Add client error: \(error.localizedDescription)")
            clouser(false)
        }
    }
    
    public func getJobTitleData(clouser: @escaping ([JobModel]) -> Void) async {
        do {
            let jobsData = try await connection?.query("select job_title_id, title from job_title", logger: logger)
            guard let jobsData = jobsData else { clouser([JobModel]()); return }
            var jobs = [JobModel]()
            for try await (id, title) in jobsData.decode((Int, String).self) {
                jobs.append(JobModel(tile: title, id: id))
            }
            clouser(jobs)
        } catch let error {
            print("Get job title error: \(error)")
            clouser([JobModel]())
        }
    }
    
    public func getEmoloyeesData(clouser: @escaping ([EmployeeModel]) -> Void) async {
        do {
            let employeesData = try await connection?.query("select name, employee_id from employee", logger: logger)
            guard let employeesData = employeesData else { clouser([EmployeeModel]()); return }
            var employees = [EmployeeModel]()
            for try await (name, id) in employeesData.decode((String, Int).self) {
                employees.append(EmployeeModel(name: name, id: id))
            }
            clouser(employees)
        } catch let error {
            print("Get employee data error: \(error.localizedDescription)")
            clouser([EmployeeModel]())
        }
    }
    
    public func register(login: String, password: String, age: Int, name: String, number: String, experience: Int, role: String, jobTitle: Int, clouser: @escaping (RegisterResults) -> Void) async {
        do {
            let loginQuery = PostgresQuery(unicodeScalarLiteral: "insert into login_data values ('\(login)', '\(password)', '\(role.lowercased())')")
            try await connection?.query(loginQuery, logger: logger)
            do {
                let est = 1
                let rating = 0
                let insertQuery = PostgresQuery(unicodeScalarLiteral: "insert into employee values (default, '\(name)', \(jobTitle), \(est), '\(number)', \(experience), \(age), \(rating), '\(login)')")
                try await connection?.query(insertQuery, logger: logger)
                clouser(.success)
            } catch let error {
                print("Insert error: \(error)")
                clouser(.employeeError)
            }
        } catch let error {
            print("Register error: \(error)")
            clouser(.loginDataError)
        }
    }
    
    public func getAllServices(clouser: @escaping ([ServiceModel]) -> Void) async {
        do {
            let query = PostgresQuery(unicodeScalarLiteral: "select service_id, name, cast(cost as varchar) from service")
            let servicesData = try await connection?.query(query, logger: logger)
            guard let servicesData = servicesData else { clouser([ServiceModel]()); return }
            var services = [ServiceModel]()
            for try await (id, name, cost) in servicesData.decode((Int, String, String).self) {
                services.append(ServiceModel(name: name, cost: cost, id: id))
            }
            clouser(services)
        } catch let error {
            print("Get all services error: \(error.localizedDescription)")
            clouser([ServiceModel]())
        }
    }
    
    public func addOrder(client: Int, employee: Int, totalCost: Double, rating: Double, date: Date, servicesID: [Int], clouser: @escaping (AddOrderResults) -> Void) async {
        do {
            let query = PostgresQuery(unicodeScalarLiteral: "insert into orders values (default, \(client), \(employee), \(totalCost), \(rating), '\(date.description)') returning order_id")
            let data = try await connection?.query(query, logger: logger)
            guard let data = data else { return }
            var orderID = -1
            for try await (id) in data.decode((Int).self) {
                orderID = id
            }
            for serviceID in servicesID {
                let serviceQuery = PostgresQuery(unicodeScalarLiteral: "insert into given_service values (default, \(orderID), \(serviceID))")
                do {
                    try await connection?.query(serviceQuery, logger: logger)
                } catch let error {
                    print("Error add service: \(error.localizedDescription)")
                    clouser(.serviceError)
                }
            }
            clouser(.success)
        } catch let error {
            print("Add order error: \(error.localizedDescription)")
            clouser(.orderError)
        }
    }
    
    public func getUpcomingOrders(clouser: @escaping ([OrderModel]) -> Void) async {
        do {
            let ordersData = try await connection?.query("select order_id, cast(total_cost as varchar), cast(orders.rating as varchar), client.name as client, employee.name as employee, date from orders join client using (client_id) join employee using (employee_id) where date >= current_timestamp", logger: logger)
            guard let ordersData = ordersData else { clouser([OrderModel]()); return }
            var orders = [OrderModel]()
            for try await (id, totalCost, rating, client, employee, date) in ordersData.decode((Int, String, String, String, String, Date).self) {
                orders.append(OrderModel(id: id, totalCost: totalCost, rating: rating, clientName: client, employeeName: employee, date: date))
            }
            clouser(orders)
        } catch let error {
            print("Get upcoming orders error: \(error.localizedDescription)")
            clouser([OrderModel]())
        }
    }
    
    public func getEmployeeReport(from: String, to: String, clouser: @escaping ([ReportModel]) -> Void) async {
        do {
            let query = PostgresQuery(unicodeScalarLiteral: "select name, phone_number, cast(round(rating,2) as varchar) from get_best_employees('\(from)', '\(to)')")
            let data = try await connection?.query(query, logger: logger)
            guard let data = data else { clouser([ReportModel]()); return }
            var report = [ReportModel]()
            for try await (first, second, third) in data.decode((String, String, String).self) {
                report.append(ReportModel(firstColumn: first, secondColumn: second, thirdColumn: third))
            }
            clouser(report)
        } catch let error {
            print("Get employee report error: \(error)")
            clouser([ReportModel]())
        }
    }
    
    public func getGeneralReport(from: String, to: String, clouser: @escaping ([ReportModel]) -> Void) async {
        do {
            let query = PostgresQuery(unicodeScalarLiteral: "select service_name, cast(cnt as varchar), cast(total_cost as varchar) from get_revenue('\(from)', '\(to)')")
            let data = try await connection?.query(query, logger: logger)
            guard let data = data else { clouser([ReportModel]()); return }
            var report = [ReportModel]()
            for try await (first, second, third) in data.decode((String, String, String).self) {
                report.append(ReportModel(firstColumn: first, secondColumn: second, thirdColumn: third))
            }
            clouser(report)
        } catch let error {
            print("Get general report error: \(error)")
            clouser([ReportModel]())
        }
    }
    
    private func setEventLoopGroup() {
        DispatchQueue.global(qos: .background).async {
            self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        }
    }
    
    private func clearData() {
        UserDefaults.standard.login = nil
        UserDefaults.standard.password = nil
        UserDefaults.standard.role = nil
    }
    
    public func exit() async {
        do {
            try await connection?.query("reset role", logger: logger)
            clearData()
            DispatchQueue.main.async { [weak self] in
                self?.login = ""
                self?.password = ""
            }
        } catch let error {
            print("Exit error: \(error.localizedDescription)")
        }
    }
}
