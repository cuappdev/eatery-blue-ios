//
//  CoreDataStack.swift
//  Eatery Blue
//
//  Created by William Ma on 1/2/22.
//

import Combine
import CoreData

class CoreDataStack {

    private let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init() {
        persistentContainer = NSPersistentContainer(name: "EateryBlue")

        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                logger.critical("\(#function): Failed to load Core Data stack: \(error)")
            } else {
                logger.info("\(#function): Successfully loaded persistent stores")
            }
        }
    }

    func save() {
        guard context.hasChanges else {
            return
        }

        do {
            try context.save()
        } catch {
            logger.critical("\(#function): Failure to save context: \(error)")
        }
    }

    func metadata(eateryId: Int64) -> EateryMetadata {
        let fetchRequest = NSFetchRequest<EateryMetadata>()
        fetchRequest.entity = EateryMetadata.entity()
        fetchRequest.predicate = NSPredicate(format: "eateryId == %d", eateryId)
        fetchRequest.fetchLimit = 1

        if let metadata = try? context.fetch(fetchRequest).first {
            return metadata

        } else {
            let metadata = EateryMetadata(context: context)
            metadata.eateryId = eateryId
            save()
            return metadata
        }
    }

}
