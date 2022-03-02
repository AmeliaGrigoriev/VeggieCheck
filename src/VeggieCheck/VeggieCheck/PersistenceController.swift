//
//  PersistenceController.swift
//  veggietest
//
//  Created by Róisín O’Rourke on 17/02/2022.
//  followed tutorial at https://www.youtube.com/watch?v=_GJlFk-Hhz8 for basic set up (init, save, delete)

import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer // create a persistent container

    init() {
        container = NSPersistentContainer(name: "Ingredients") // load the db
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
        }
    }

    // save an changes to the database
    func save(completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        if context.hasChanges { // check if any changes have been made
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    // delete an item from the database
    func delete(_ object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        context.delete(object)

        save(completion: completion) // save the changes
    }
    
    // delete the oldest item in the previous searches database
    func deleteFirst(with email: String, completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<UserSearches> // fetch the User Searches searches
        fetchRequest = UserSearches.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "email LIKE[cd] %@", email) // for the user logged in
        do {
            if (try container.viewContext.fetch(fetchRequest).first != nil) {
                let object = try container.viewContext.fetch(fetchRequest).first
                // delete the first object
                context.delete(object!)
            }
        } catch {
            print("error")
        }
        
        save(completion: completion) // save the changes
    }

    // check if an ingredient is in the database
    func fetchIngredient(with ingredient: String) -> Bool {

        let fetchRequest: NSFetchRequest<Vegan>
        fetchRequest = Vegan.fetchRequest()
        var isVegan: Bool = true // set isVegan to true
        // fetch the ingredient passed to the function
        fetchRequest.predicate = NSPredicate(format: "ingredient LIKE[cd] %@", ingredient)

        do {
            if (try container.viewContext.fetch(fetchRequest).first != nil) {
                isVegan = false // if the ingredient is found -> not vegan
            }
        } catch {
            print("error")
        }
        return isVegan // return the status of fetch
    }
    
    // fetch the search history of the user logged in
    func fetchSearches(with email: String) -> [UserSearches]? {

        let fetchRequest: NSFetchRequest<UserSearches>
        fetchRequest = UserSearches.fetchRequest()
        // fetch the searches with the current user's email address
        fetchRequest.predicate = NSPredicate(format: "email LIKE[cd] %@", email)

        do {
            return try container.viewContext.fetch(fetchRequest) // return the searches
            
        } catch {
            print("error")
            return nil
        }
    }
}
