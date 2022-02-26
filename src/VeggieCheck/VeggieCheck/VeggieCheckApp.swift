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
    
    let persistenceController = PersistenceController.shared
//
    func addIngredients() -> [String] {

        var myStrings: [String] = []

        if let path = Bundle.main.path(forResource: "nonveganlist", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let lowerIngredients = data.lowercased()
                myStrings = lowerIngredients.components(separatedBy: .newlines)
//                print(myStrings)

            } catch {
                print(error)
            }
        }
        return myStrings
    }
//
//    func pListCreation() {
//        let fileManager = FileManager.default
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
//        let documentsDirectory = paths.object(at: 0) as! NSString
//        let path = documentsDirectory.appendingPathComponent("NonVeganIngredients.plist")
//
//        if (!fileManager.fileExists(atPath: path)) {
//            let Array = addIngredients()
//            let plistContent = NSArray(array: Array)
//            let success:Bool = plistContent.write(toFile: path, atomically: true)
//            if success {
//                print("file has been created!")
//            }else{
//                print("unable to create the file")
//            }
//
//        }else{
//            print("file already exist")
//        }
//    }
//
//    func hello() {
//        print("im working")
//    }
//
    private func preLoadData() {
        let preloadedDataKey = "didPreloadData"
        print("1")
        let userDefaults = UserDefaults.standard

        if userDefaults.bool(forKey: preloadedDataKey) == false {

            print("2")
            let backgroundContext = persistenceController.container.newBackgroundContext()
            persistenceController.container.viewContext.automaticallyMergesChangesFromParent = true

            backgroundContext.perform {
//
                print("4")
                if let arrayContents = addIngredients() as? [String] {
                    do {
                        print("5")
                        for item in arrayContents {
                            let veganObject = Vegan(context: backgroundContext)
                            veganObject.ingredient = item
//                            print(item)
                        }
                        try backgroundContext.save()
                        userDefaults.set(true, forKey: preloadedDataKey)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
//
    init() {
//        pListCreation()
//        hello()
        preLoadData()
    }
    
    @Environment(\.scenePhase) var scenePhase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var sessionService = SessionServiceImpl()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch sessionService.state {
                    case .loggedIn:
                        HomeView()
                            .environmentObject(sessionService)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    case .loggedOut:
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
