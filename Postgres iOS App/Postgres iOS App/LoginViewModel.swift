//
//  LoginViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 23.04.2023.
//

import PostgresKit

class LoginViewModel {
    
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let logger = Logger(label: "postgres-logger")
    private var connection: PostgresConnection? = nil
    
    public func connect(login: String, password: String) async {
        guard let sslContext = try? NIOSSLContext(configuration: .clientDefault) else { return }
        
        let configuration = PostgresConnection.Configuration(
            host: "ep-shiny-sunset-642465.eu-central-1.aws.neon.tech",
            username: login,
            password: password,
            database: "neondb",
            tls: .require(sslContext)
        )
        
        do {
            connection = try await PostgresConnection.connect(on: eventLoopGroup.next(), configuration: configuration, id: 1, logger: logger)
        } catch let error {
            print("error: \(error)")
        }
    }
}
