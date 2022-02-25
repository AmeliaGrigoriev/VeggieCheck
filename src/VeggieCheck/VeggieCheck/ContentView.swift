//
//  ContentView.swift
//  VeggieCheck
//
//  Created by Amelia Grigoriev on 24/01/2022.
//

import SwiftUI

enum VeganAlert {
    case vegan, nonvegan
}

struct ContentView: View {
//    @EnvironmentObject var sessionService: SessionServiceImpl
    
    @ObservedObject var recognizedContent = RecognizedContent()
    @State private var showScanner = false
    @State private var isRecognizing = false
    @State private var ingredient: String = ""
    @State private var veganAlert: VeganAlert = .vegan
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack() {
//                List(recognizedContent.items, id: \.id) { textItem in
//                    NavigationLink(destination: TextPreviewView(text: textItem.text)) {
//                        Text(String(textItem.text.prefix(50)).appending("..."))
//                    }
//                }
                HStack(spacing: 16) {
                    
//                    VStack(spacing: 10) {
//                        Text("\(sessionService.userDetails?.firstName ?? "N/A") \(sessionService.userDetails?.lastName ?? "N/A")").font(.system(size: 22))
//                    }
//                                
//                    ButtonView(title: "Logout") {
//                        sessionService.logout()
//                    }
                }
                Button(action: {
                    guard !isRecognizing else { return }
                    showScanner = true
                }) {
                    Text("Scan Ingredients")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(40)
                        .foregroundColor(.white)
                        .padding(10)

                }

                TextField("Enter Ingredient", text: $ingredient, onCommit: {
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
                          
                ).padding()
                
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
            
            .navigationTitle("Veggie Check")
            
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .environmentObject(SessionServiceImpl())
    }
}

