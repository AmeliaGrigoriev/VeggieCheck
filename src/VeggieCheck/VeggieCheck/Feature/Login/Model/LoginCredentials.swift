//
//  LoginCredentials.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//
// followed tutorial at: https://www.youtube.com/watch?v=5gIuYHn9nOc for firebase authentication

import Foundation

struct LoginCredentials {
    var email: String
    var password: String
}

extension LoginCredentials {
    
    static var new: LoginCredentials {
        LoginCredentials(email: "", password: "")
    }
}
