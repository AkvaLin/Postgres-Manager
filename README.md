# Postgres-Manager

## About

An application for remote work with psql database. The application uses PostgresKit (Vapor) using SwiftNIO. Allows you to view and edit psql tables.

## Terms of reference:
Based on the database you created, a graphical interface for the database with the following functionality:
- Registration of new users with a choice of roles (user passwords must be encrypted)
- Separate display of available information for each of the roles, depending on privileges and access from works 2-6
- Automatic job review (depending on the functionality of roles from 2-6 jobs)
- Creating applications, assigning responsible persons and specifying the date 
- Customer search
- Employee reporting
- Separate reporting on tasks

## Screenshots

| Login | Orders | Clients |
| :-------------: |:-------------:|:-------------:|
| <img src="https://i.ibb.co/0cHX4SR/Picture-9.png"> | <img src="https://i.ibb.co/JBBYv9X/Picture-4.png"> | <img src="https://i.ibb.co/tP3n0Lq/Picture-5.png"> |
| Administrator | New order | Report |
| <img src="https://i.ibb.co/yFkZ33f/Picture-1.png"> | <img src="https://i.ibb.co/0rQbYnh/Picture-6.png"> | <img src="https://i.ibb.co/JdTXG5w/Picture-8.png"> |

## Technical Description

- SwiftUI
- MVVM
- UserDefaults
- [PostgresKit](https://github.com/martinrybak/SQLClient](https://github.com/vapor/postgres-kit)
- SPM
- Concurrency
- Combine
