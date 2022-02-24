//
//  HomeView.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
        VStack {
            HStack(spacing: 16) {
                
                VStack(spacing: 10) {
                    Text("Hello").font(.system(size: 22))
                }
                            
                ButtonView(title: "Logout") {
                    // TODO: handle logout action here
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
        }
    }
}
