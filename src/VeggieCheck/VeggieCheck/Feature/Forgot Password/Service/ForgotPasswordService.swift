//
//  ForgotPasswordService.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 23/02/2022.
//

import Combine
import Foundation
import FirebaseAuth

protocol ForgotPasswordService {
    func sendPasswordReset(to email: String) -> AnyPublisher<Void, Error>
}

final class ForgotPasswordServiceImpl: ForgotPasswordService {
    
    func sendPasswordReset(to email: String) -> AnyPublisher<Void, Error> {
        
        Deferred {
            
            Future { promise in
                
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    
                    if let err = error {
                        promise(.failure(err))
                    } else {
                        promise(.success(()))
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
}
