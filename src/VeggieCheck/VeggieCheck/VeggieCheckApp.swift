//
//  VeggieCheckApp.swift
//  VeggieCheck
//
//  Created by Amelia Grigoriev on 24/01/2022.
//

import SwiftUI
import Firebase

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct VeggieCheckApp: App {
    
    let persistenceController = PersistenceController.shared // for Core Data
//
    func addIngredients() -> [String] { // take the ingredients from nonveganlist.txt and turn into array

        var ingredientArray: [String] = []

        if let path = Bundle.main.path(forResource: "nonveganlist", ofType: "txt") { // open the txt file
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8) // turn it into a string
                let lowerIngredients = data.lowercased()
                ingredientArray = lowerIngredients.components(separatedBy: .newlines) // split by newlines

            } catch {
                print(error)
            }
        }
        return ingredientArray // return the array
    }

    // followed tutorial at https://www.youtube.com/watch?v=hrwx_teqwdQ
    private func preLoadData() { // preload the ingredients into the database
        let preloadedDataKey = "didPreloadData"
        let userDefaults = UserDefaults.standard

        if userDefaults.bool(forKey: preloadedDataKey) == false { // check that data hasnt already been loaded

            let backgroundContext = persistenceController.container.newBackgroundContext()
            persistenceController.container.viewContext.automaticallyMergesChangesFromParent = true

            backgroundContext.perform { // in the background
                if let arrayContents = addIngredients() as? [String] { // use the list of ingredients
                    do {
                        for item in arrayContents { // go through array and add to db
                            let veganObject = Vegan(context: backgroundContext)
                            veganObject.ingredient = item
                        }
                        try backgroundContext.save() // save the ingredients to the database
                        userDefaults.set(true, forKey: preloadedDataKey) // ingredients have been loaded
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    init() {
        preLoadData()
    }
    
    @Environment(\.scenePhase) var scenePhase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var sessionService = SessionServiceImpl()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch sessionService.state {
                    case .loggedIn: // if the user is logged in show the home view
                        HomeView()
                            .environmentObject(sessionService)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    case .loggedOut: // else show the log in page
                        LoginView()
                    }
                
            }
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {

            case .background:
                print("Scene is in background")
                persistenceController.save()
            case .inactive:
                print("Scene is inactive")
            case .active:
                print("Scene is active")
            @unknown default:
                print("Something is different")
            }
        }
    }
}
