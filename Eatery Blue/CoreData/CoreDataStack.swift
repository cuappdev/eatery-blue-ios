//
//  CoreDataStack.swift
//  Eatery Blue
//
//  Created by William Ma on 1/2/22.
//

import Combine
import CoreData

class CoreDataStack: NSObject {

    private let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    override init() {
        persistentContainer = NSPersistentContainer(name: "EateryBlue")

        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                logger.critical("\(#function): Failed to load Core Data stack: \(error)")
            } else {
                logger.info("\(#function): Successfully loaded persistent stores")
            }
        }
    }

    func fetch<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        fetchLimit: Int? = nil
    ) -> Future<[T], Error> {

        Future { [self] fulfill in
            let request = NSFetchRequest<T>()
            request.entity = T.entity()
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors

            if let fetchLimit = fetchLimit {
                request.fetchLimit = fetchLimit
            }

            context.perform {
                do {
                    let results = try context.fetch(request)
                    fulfill(.success(results))
                } catch {
                    fulfill(.failure(error))
                }
            }
        }
    }

    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        T(context: context)
    }

    func save() {
        do {
            try context.save()
        } catch {
            logger.critical("\(#function): Failure to save context: \(error)")
        }
    }

}
