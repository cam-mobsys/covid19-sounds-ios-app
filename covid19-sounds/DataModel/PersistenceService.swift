//
//  PersistenceService.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import CoreData

/// This is our persistence service used to interface with the actual database on file.
///
class PersistenceService {
  /// private constructor enforcing the singleton pattern.
  private init() {}
  /// the shared, global, instance of the persistence service.
  static let shared = PersistenceService()
  /// the database name.
  private let dbName = "CoreDataSoundsApp"
  /// the managed context instance.
  var ctx: NSManagedObjectContext { return persistentContainer.viewContext }
  /// Internal function that constructs the description for the persistent context (essentially, its configuration).
  ///
  /// Enabled the following migration descriptions:
  ///
  ///  - `shouldMigrateStoreAutomatically`: to migrate schemas automatically.
  ///  - `shouldInferMappingModelAutomatically`: to automatically infer model mapping.
  ///
  /// - Returns: populated instance of `NSPersistentStoreDescription` with the required properties
  ///
  private func constructPersistentStoreDescriptions() -> [NSPersistentStoreDescription] {
    // construct the db path location
    let dbURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let dbURL = dbURLs[dbURLs.count-1].appendingPathComponent(dbName + ".sql")
    let dbURLDescription = NSPersistentStoreDescription(url: dbURL)
    // code that allows automatic model migration.
    let migrationDescription = NSPersistentStoreDescription()
    migrationDescription.shouldMigrateStoreAutomatically = true
    migrationDescription.shouldInferMappingModelAutomatically = true
    // return the descriptions
    return [dbURLDescription, migrationDescription]
  }
  //
  // MARK: - Core Data stack
  //
  /// this is the variable that holds the `NSPersistentContainer` instance and is _lazy_ evaluated.
  private lazy var persistentContainer: NSPersistentContainer = {
    // get the container using our db name
    let container = NSPersistentContainer(name: dbName)
    // construct the descriptions
    container.persistentStoreDescriptions = constructPersistentStoreDescriptions()
    // try to load the persistent stores
    container.loadPersistentStores(completionHandler: { (_, error) in
      //log.info(storeDescription.configuration!)
      if let error = error as NSError? {
        // practically speaking this should never happen, so we leave it here.
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  //
  // MARK: - Core Data Saving support
  //
  /// Function that is used to commit the changes to the persistent store.
  ///
  func save() {
    log.info("SAVE was INVOKED.")
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // we want this to crash in case something goes terribly wrong.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
    log.info("SAVE was SUCCESSFUL.")
  }
  //
  // MARK: - Core Data Flush support
  //
  /// Function that is used to flush (i.e.: delete) everything from the data store.
  ///
  func flush() {
    log.info("FLUSH was INVOKED.")
    guard let persistentStoreURL = persistentContainer.persistentStoreDescriptions.first?.url else {
      log.error("Could not flush database - the persistent store URL could not be unwrapped.")
      return
    }
    let coord = persistentContainer.persistentStoreCoordinator
    do {
      // flush the persistent store by wiping it.
      try coord.destroyPersistentStore(at: persistentStoreURL,
                                       ofType: NSSQLiteStoreType,
                                       options: nil)
      // now recreate it.
      try coord.addPersistentStore(ofType: NSSQLiteStoreType,
                                   configurationName: nil,
                                   at: persistentStoreURL,
                                   options: nil)
    } catch let error {
      // if any error was encountered, report it.
      log.error("Failed to clear persistent store, reason: \(error.localizedDescription).")
      return
    }
    log.info("FLUSH was SUCESSFUL")
  }
}
