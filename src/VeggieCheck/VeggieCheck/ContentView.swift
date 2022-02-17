//
//  ContentView.swift
//  VeggieCheck
//
//  Created by Amelia Grigoriev on 24/01/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var recognizedContent = RecognizedContent()
    @State private var showScanner = false
    @State private var isRecognizing = false
    @State private var ingredient: String = ""
    @State private var showingVeganAlert = false
    @State private var showingNonVeganAlert = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List(recognizedContent.items, id: \.id) { textItem in
                    NavigationLink(destination: TextPreviewView(text: textItem.text)) {
                        Text(String(textItem.text.prefix(50)).appending("..."))
                    }
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

                TextField("Enter Ingredient", text: $ingredient,
                          onCommit: {
                    API().getResults(ingredients: ingredient) { Checker in
                        if Checker.isVeganSafe {
//                            print("vegan safe")
                            showingVeganAlert = true
                        }
                        else {
                            showingNonVeganAlert = true
                        }
                    }
                }
                ).padding()
                
                if isRecognizing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemIndigo)))
                        .padding(.bottom, 20)
                }
                
            }
            .alert("Ingredient entered is vegan friendly", isPresented: $showingVeganAlert) {
                        Button("OK", role: .cancel) { }
                    }
            .alert("Ingredient entered is not vegan friendly", isPresented: $showingNonVeganAlert) {
                        Button("OK", role: .cancel) { }
                    }
            .navigationTitle("Veggie Check")
//            .navigationBarItems(trailing: Button(action: {
//                guard !isRecognizing else { return }
//                showScanner = true
//            }, label: {
//                HStack {
//                    Image(systemName: "doc.text.viewfinder")
//                        .renderingMode(.template)
//                        .foregroundColor(.white)
//
//                    Text("Scan")
//                        .foregroundColor(.white)
//                }
//                .padding(.horizontal, 16)
//                .frame(height: 36)
//                .background(Color(UIColor.systemIndigo))
//                .cornerRadius(18)
//            }))
            
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
    }
}

