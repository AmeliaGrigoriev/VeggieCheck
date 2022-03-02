//
//  HomeView.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var sessionService: SessionServiceImpl
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var ingredient: String = ""
    @State private var veganAlert: VeganAlert = .vegan
    @State private var showAlert = false
    @State private var showScanner = false
    @State private var isRecognizing = false
    
    @ObservedObject var recognizedContent = RecognizedContent()
    @ObservedObject var networkChecker = NetworkChecker()
    
    var body: some View {
        
        VStack {

            Spacer()
            
            Group {
                VStack {
                    Text("Search individual ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                        .foregroundColor(Color.white)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Enter Ingredient", text: $ingredient, onCommit: {
                            if (networkChecker.isConnected) {
                                API().getResults(ingredients: ingredient) { Checker in
                                    if Checker.isVeganSafe {
                                        veganAlert = .vegan
                                        print("vegan safe")
                                    }
                                    else {
                                        veganAlert = .nonvegan
                                        print("not vagan safe")
                                    }
                                    showAlert = true
                                }
                            }
                            else {
                                if (PersistenceController.shared.fetchIngredient(with: ingredient)) {
                                    veganAlert = .vegan
                                    print("vegan safe - no wifi")
                                }
                                else {
                                    veganAlert = .nonvegan
                                    print("not vagan safe - no wifi")
                                }
                                showAlert = true
                            }
                            
                        }
                                  
                        )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }.padding([.bottom, .trailing, .leading])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(red: 114.0/255, green: 235.0/255, blue: 99.0/255, alpha: 1.0)))
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            Group {
                NavigationLink {
                    ShowIngredientsView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                } label: {
                    Text("List of Non Vegan Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(red: 114.0/255, green: 235.0/255, blue: 99.0/255, alpha: 1.0)))
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            Group {
                Button(action: {
                    guard !isRecognizing else { return }
                    showScanner = true
                }) {
                    Text("Scan Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .background(Color(UIColor(red: 114.0/255, green: 235.0/255, blue: 99.0/255, alpha: 1.0)))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(red: 114.0/255, green: 235.0/255, blue: 99.0/255, alpha: 1.0)))
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            Group {
                VStack {
                    Text("Search History")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 5)
                        
                    NavigationLink {
                        CheckedView(recognizedContent: recognizedContent, email: "\(sessionService.userDetails?.email ?? "N/A")")
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    } label: {
                        HStack {
                            Text(String(recognizedContent.items.last?.text.prefix(20) ?? "No recent searches"))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(UIColor(red: 0.0/255, green: 21.0/255, blue: 156.0/255, alpha: 1.0)))
                                .padding(.bottom, 5)
                            Image(systemName: "chevron.right")
                        }
                        
                    }
                    NavigationLink {
                        SearchesView(email: "\(sessionService.userDetails?.email ?? "N/A")")
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    } label: {
                        Text("View Previous Searches")
//                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(UIColor(red: 0.0/255, green: 21.0/255, blue: 156.0/255, alpha: 1.0)))
//                            .padding(.top)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor(red: 114.0/255, green: 235.0/255, blue: 99.0/255, alpha: 1.0)))
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            if isRecognizing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemIndigo)))
                    .padding(.bottom, 20)
            }
        }
        .alert(isPresented: $showAlert) {
            switch veganAlert {
            case .vegan:
                return Alert(title: Text("Vegan Check"), message: Text("Ingredient entered is vegan friendly"), dismissButton: .default(Text("Got it!")))
            case .nonvegan:
                return Alert(title: Text("Vegan Check"), message: Text("Ingredient entered is not vegan friendly"), dismissButton: .default(Text("Got it!")))
            }
        }
        .navigationTitle("VeggieCheck")
        .navigationBarItems(trailing: Button(action: {
            sessionService.logout()
        }, label: {
            HStack {
                Text("Log out")
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(Color.green)
            .cornerRadius(18)
        }))

        .sheet(isPresented: $showScanner, content: {
            ScannerView { result in
                switch result {
                    case .success(let scannedImages):
                        isRecognizing = true
                        
                        TextRecognition(scannedImages: scannedImages,
                                        recognizedContent: recognizedContent) {
                            // Text recognition is finished, hide the progress indicator.
                            isRecognizing = false
                        }
                        .recognizeText()

                    case .failure(let error):
                        print(error.localizedDescription)
                }
                
                showScanner = false
                
            } didCancelScanning: {
                // Dismiss the scanner controller and the sheet.
                showScanner = false
            }
        })
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
