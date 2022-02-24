//
//  HomeView.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var sessionService: SessionServiceImpl
    
    var body: some View {
        
        VStack {
            HStack(spacing: 16) {
                
                VStack(spacing: 10) {
                    Text("\(sessionService.userDetails?.firstName ?? "N/A") \(sessionService.userDetails?.lastName ?? "N/A")").font(.system(size: 22))
                }
                            
                ButtonView(title: "Logout") {
                    sessionService.logout()
                }
            }
            .padding(.horizontal, 16)
            .navigationTitle("VeggieCheck")
            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .environmentObject(SessionServiceImpl())
        }
    }
}
