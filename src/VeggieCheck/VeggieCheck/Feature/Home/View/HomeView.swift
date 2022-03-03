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
    
    // declare variables for the view
    @State private var ingredient: String = ""
    @State private var veganAlert: VeganAlert = .vegan
    @State private var showAlert = false
    @State private var showScanner = false
    @State private var isRecognizing = false
    
    @ObservedObject var recognizedContent = RecognizedContent()
    @ObservedObject var networkChecker = NetworkChecker()
    
    var body: some View {
        
        VStack { // create a verticle stack for all the elements of the home page

            Spacer()
            
            Group { // first group is individual ingredient search entry
                VStack {
                    Text("Search individual ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                        .foregroundColor(Color.white)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Enter Ingredient", text: $ingredient, onCommit: {
                            if (networkChecker.isConnected) { // check if user has internet
                                // if yes, pass the ingredient to the API
                                ingredient = ingredient.replacingOccurrences(of: " ", with: "%20") // change to use in URL
                                API().getResults(ingredients: ingredient) { Checker in
                                    if Checker.isVeganSafe { // if API returns vegan safe
                                        veganAlert = .vegan // set alert to show vegan friendly
                                        print("vegan safe")
                                    }
                                    else {
                                        veganAlert = .nonvegan
                                        print("not vagan safe")
                                    }
                                    showAlert = true // show the is vegan notification
                                }
                            }
                            else { // if not connected to the internet
                                // check if the ingredient is in the database
                                if (PersistenceController.shared.fetchIngredient(with: ingredient)) {
                                    veganAlert = .vegan
                                    print("vegan safe - no wifi")
                                }
                                else { // if the ingredient is not found
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
            .background(Color.green)
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            Group { // box to show the list of non vegan ingredients
                NavigationLink {
                    ShowIngredientsView() // go to the view with the list
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                } label: {
                    Text("List of Non Vegan Ingredients") // label for the link
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            Group { // box for button for scanning ingredients
                Button(action: {
                    guard !isRecognizing else { return } // if it isnt running text recognition on something else
                    showScanner = true // open the camera
                }) {
                    Text("Scan Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .background(Color.green)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            Group { // box for the search history
                VStack {
                    Text("Search History")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 5)
                        
                    NavigationLink { // view the most recent search
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
                    NavigationLink { // view the list of previous searches
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
            .background(Color.green)
            .cornerRadius(10)
            .padding([.bottom, .trailing, .leading])
            
            if isRecognizing { // if text recognition is running
                ProgressView() // show the loading symbol
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.green))
                    .padding(.bottom, 20)
            }
        }
        .alert(isPresented: $showAlert) { // pop up notification for the individual vegan check
            switch veganAlert {
            case .vegan:
                return Alert(title: Text("Vegan Check"), message: Text("Ingredient entered is vegan friendly"), dismissButton: .default(Text("Got it!")))
            case .nonvegan:
                return Alert(title: Text("Vegan Check"), message: Text("Ingredient entered is not vegan friendly"), dismissButton: .default(Text("Got it!")))
            }
        }
        .navigationTitle("VeggieCheck")
        .navigationBarItems(trailing: Button(action: { // log out button in the top right corner
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
        
        // followed tutorial at https://www.appcoda.com/swiftui-text-recognition/
        .sheet(isPresented: $showScanner, content: { // open the camera
            ScannerView { result in
                switch result {
                    case .success(let scannedImages): // if the image capture was succesful
                        isRecognizing = true // show the loading symbol
                        
                        TextRecognition(scannedImages: scannedImages, // pass the images taken to the tr class
                                        recognizedContent: recognizedContent) {
                            // Text recognition is finished, hide the progress indicator.
                            isRecognizing = false
                        }
                        .recognizeText() // run text recognition

                    case .failure(let error):
                        print(error.localizedDescription)
                }
                
                showScanner = false // hide the scanner view
                
            } didCancelScanning: { // if user left scanner without taking a picture
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
