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
    
    // Database settings
    private let host = "db.tjytbokwkceokguvmtrh.supabase.co"
    private let database = "postgres"
    private let login = "postgres"
    private let password = "xyhwu2-nesded-poWqad"
    
    private var eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    private let logger = Logger(label: "postgres-logger")
    private var connection: PostgresConnection? = nil
    
    init() {
        setEventLoopGroup()
    }
    
    public func connect(login: String, password: String, completion: @escaping (LoginResults) -> Void) async {
        do {
            try await connection?.close()
        } catch let error {
            print("cannot close connection: \(error)")
            completion(.unknownError)
        }
        
        guard let eventLoopGroup = eventLoopGroup else { return }
        
        let configuration = PostgresConnection.Configuration(
            host: host,
            username: self.login,
            password: self.password,
            database: database,
            tls: .disable
        )
        
        do {
            connection = try await PostgresConnection.connect(on: eventLoopGroup.next(), configuration: configuration, id: 1, logger: logger)
        } catch let error {
            print("error: \(error)")
            completion(.connectionError)
            return
        }
        
        do {
            let checkPassword = try await connection?.query("SELECT check_password(\(login), \(password))", logger: logger)
            guard let checkPassword = checkPassword else { completion(.dataError); return }
            do {
                for try await result in checkPassword.decode((Bool).self) {
                    if result {
                        let rows = try await connection?.query("SELECT * FROM login_data WHERE login = \(login)", logger: logger)
                        guard let rows = rows else { completion(.dataError); return }
                        for try await row in rows {
                            let roleCell = row.first { cell in
                                cell.columnName == "role"
                            }
                            guard let roleCell = roleCell else {
                                completion(.dataError)
                                return
                            }
                            let role = try roleCell.decode((String).self)
                            print("Login succed with role \(role)")
                            do {
                                let query = PostgresQuery(unicodeScalarLiteral: "SET ROLE \(role)")
                                try await connection?.query(query, logger: logger)
                                if isSaveEnabled {
                                    UserDefaults.standard.login = login
                                    UserDefaults.standard.password = password
                                    UserDefaults.standard.role = role
                                }
                                completion(.success)
                            } catch let error {
                                print("Role didnt change: \(error)")
                                clearData()
                                completion(.connectionError)
                            }
                        }
                    } else {
                        print("Wrong password")
                        clearData()
                        completion(.passwordError)
                        return
                    }
                }
            } catch {
                print("User doesnt exist")
                clearData()
                completion(.loginError)
                return
            }
        } catch let error {
            print("query error: \(error)")
            clearData()
            completion(.queryError)
            return
        }
    }
    
    public func getAllClientsData() async -> [ClientModel] {
        do {
            let clientsData = try await connection?.query("select * from client join client_status using (client_status_id)", logger: logger)
            guard let clientsData = clientsData else { return [ClientModel]() }
            var clients = [ClientModel]()
            for try await (_, client_id, phone_number, email, name, title, _) in clientsData.decode((Int, Int, String, String, String, String, Int).self) {
                clients.append(ClientModel(id: client_id, name: name, phoneNumber: phone_number, email: email, status: title))
            }
            return clients
        } catch {
            return [ClientModel]()
        }
    }
    
    public func deleteClientRow(id: Int) async {
        do {
            try await connection?.query("CALL delete_client(\(id)", logger: logger)
        } catch {
            
        }
    }
    
    public func addClientRow(phoneNumber: String, email: String, name: String) async {
        do {
            try await connection?.query("insert into client values (default, \(phoneNumber), \(email), 1, \(name)", logger: logger)
        } catch {
            
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
}
