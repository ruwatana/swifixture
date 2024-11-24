//
//  ContentView.swift
//  Example
//
//  Created by Wataru Namiki on 2024/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var users: [User]?
    
    var body: some View {
        NavigationStack {
            Group {
                if let users {
                    List(users, id: \.id) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text("age: \(user.age)")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Text(user.role == .admin ? "Admin" : "User")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                                .padding(4)
                                .background(user.role == .admin ? Color.red : Color.cyan)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Users")
            .onAppear {
                Task {
                    users = await UserRepositoryStub.fetchUsers()
                }
            }
        }
    }
}

/// @fixturable(override: role = .user)
struct User {
    enum Role {
        case admin
        case user
    }
    
    let id: Int
    let name: String
    let age: Int
    let role: Role
}

struct UserRepositoryStub {
    static func fetchUsers() async -> [User] {
        try? await Task.sleep(for: .seconds(1))
        
        return [
            .fixture(name: "Alice", age: 20),
            .fixture(id: 1, name: "Bob", age: 30, role: .admin),
            .fixture(id: 2, name: "Charlie", age: 40)
        ]
    }
}

#Preview {
    ContentView(users: [
        .fixture(name: "Alice", age: 20),
        .fixture(id: 1, name: "Bob", age: 30, role: .admin),
        .fixture(id: 2, name: "Charlie", age: 40)
    ])
}
