//
//  CheckNetwork.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 26/02/2022.
//  followed tutorial at https://www.youtube.com/watch?v=YIx3e0xWKtk

import Foundation
import Network

// class to check if the user is connected to the internet
class NetworkChecker: ObservableObject {
    let monitor = NWPathMonitor() // create a monitor for the network
    let queue = DispatchQueue(label: "NetworkChecker")
    @Published var isConnected = true // bool variable the internet that will update
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if (path.status == .satisfied) { // satisfied -> there is internet
                    self.isConnected = true
                } else {
                    self.isConnected = false
                }
            }
        }
        monitor.start(queue: queue) // start the monitor to always look for internet status
    }
}

