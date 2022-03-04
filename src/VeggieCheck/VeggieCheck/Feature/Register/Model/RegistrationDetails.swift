//
//  RegistrationDetails.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//
// followed tutorial at: https://www.youtube.com/watch?v=5gIuYHn9nOc for firebase authentication

import Foundation

struct RegistrationDetails {
    var email: String
    var password: String
    var firstName: String
    var lastName: String
}

extension RegistrationDetails {
    
    static var new: RegistrationDetails {
        RegistrationDetails(email: "",
                            password: "",
                            firstName: "",
                            lastName: "")
    }
}
