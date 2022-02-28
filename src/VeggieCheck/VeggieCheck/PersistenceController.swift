//
//  PersistenceController.swift
//  veggietest
//
//  Created by Róisín O’Rourke on 17/02/2022.
// https://www.youtube.com/watch?v=_GJlFk-Hhz8

import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Ingredients")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
        }
    }

    func save(completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func delete(_ object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        context.delete(object)

        save(completion: completion)
    }

    func fetchIngredient(with ingredient: String) -> Bool {

        let fetchRequest: NSFetchRequest<Vegan>
        fetchRequest = Vegan.fetchRequest()
        var isVegan: Bool = true

        fetchRequest.predicate = NSPredicate(format: "ingredient LIKE[cd] %@", ingredient)

        do {
            if (try container.viewContext.fetch(fetchRequest).first != nil) {
                isVegan = false
            }
        } catch {
            print("error")
        }
        return isVegan
    }
    
    func fetchSearches(with email: String) -> [UserSearches]? {

        let fetchRequest: NSFetchRequest<UserSearches>
        fetchRequest = UserSearches.fetchRequest()
//        var isVegan: Bool = true

        fetchRequest.predicate = NSPredicate(format: "email LIKE[cd] %@", email)

        do {
            return try container.viewContext.fetch(fetchRequest)
//                isVegan = false
            
        } catch {
            print("error")
            return nil
        }
//        return isVegan
    }
}
