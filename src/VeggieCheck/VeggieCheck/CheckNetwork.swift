//
//  CheckNetwork.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 26/02/2022.
// https://www.youtube.com/watch?v=YIx3e0xWKtk

import Foundation
import Network

class NetworkChecker: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkChecker")
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if (path.status == .satisfied) {
                    self.isConnected = true
                } else {
                    self.isConnected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}

