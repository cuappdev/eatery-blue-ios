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

    func metadata(itemName: String) -> ItemMetadata {
        let fetchRequest = NSFetchRequest<ItemMetadata>()
        fetchRequest.entity = ItemMetadata.entity()
        fetchRequest.predicate = NSPredicate(format: "itemName == %@", itemName)
        fetchRequest.fetchLimit = 1

        if let metadata = try? context.fetch(fetchRequest).first {
            return metadata

        } else {
            let metadata = ItemMetadata(context: context)
            metadata.itemName = itemName
            metadata.isFavorite = false
            save()
            return metadata
        }
    }

    func fetchFavoriteItems() -> [ItemMetadata] {
        let fetchRequest = NSFetchRequest<ItemMetadata>()
        fetchRequest.entity = ItemMetadata.entity()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch favorite items: \(error)")
            return []
        }
    }

}
