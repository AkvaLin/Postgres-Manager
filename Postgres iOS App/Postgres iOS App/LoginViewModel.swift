//
//  LoginViewModel.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 23.04.2023.
//

import Foundation
import PostgresKit

class LoginViewModel: ObservableObject {
    
    private var eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    private let logger = Logger(label: "postgres-logger")
    private var connection: PostgresConnection? = nil
    
    init() {
        setEventLoopGroup()
    }
    
    public func connect(login: String, password: String) async {
        guard let sslContext = try? NIOSSLContext(configuration: .clientDefault) else { return }
        guard let eventLoopGroup = eventLoopGroup else { return }
        
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
    
    private func setEventLoopGroup() {
        DispatchQueue.global(qos: .background).async {
            self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        }
    }
}
