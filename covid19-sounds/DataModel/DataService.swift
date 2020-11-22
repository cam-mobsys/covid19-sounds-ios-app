//
//  DataService.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos (main contributor)
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import CoreData

/// Data service which is used to interface with the `PersistenceService` which directly modifies
/// our `CoreData` based data store.
///
class DataService {
  /// the public instance of the singleton for `DataService`.
  static let shared = DataService()
  /// get the persistence service instance.
  private let ps = PersistenceService.shared
  /// do it as a singleton.
  private init() {}
  /// This function returns the `PersistenceService` context to be used.
  ///
  /// - Returns: the initialised `NSManagedObjectContext` context instance.
  ///
  func getContext() -> NSManagedObjectContext {
    return ps.ctx
  }
  /// This function returns the number of entities stored within `CoreData` that are of type `entity`.
  ///
  /// - Returns: the number of entities as `Int`, if found - otherwise, `nil`.
  ///
  func count(entity: String) -> Int? {
    do {
      let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
      let cnt = try ps.ctx.count(for: fetchReq)
      return cnt
    } catch {
      log.error(error.localizedDescription)
      return nil
    }
  }
  /// This function returns the number of entities stored within `CoreData` but uses generics to infer
  /// the object `Type`.
  ///
  /// - Parameter type: the type of the `T` object that is some `NSManagedObject`.
  ///
  /// - Returns: the number of entities as `Int`, if found - otherwise, `nil`.
  ///
  func count<T: NSManagedObject>(_ type: T.Type) -> Int? {
    let (req, name) = fetchRequestFromType(type)
    do {
      let cnt = try ps.ctx.count(for: req)
      return cnt
    } catch {
      log.error("Error while counting objects of type \(name), " +
                  "reason: \(error.localizedDescription)")
      return nil
    }
  }
  /// This function is responsible for asynchronously fetching the objects from `CoreData` given
  /// their type `T`; upon completion a `completion` handler is invoked.
  ///
  /// - Parameter type: the type of the `T` object that is some `NSManagedObject`.
  ///
  /// - Parameter completion:the completion handler to be invoked one we fetch the objects.
  ///
  func fetchAsync<T: NSManagedObject>(_ type: T.Type, completion: @escaping ([T]) -> Void) {
    let (req, name) = fetchRequestFromType(type)
    do {
      log.error("Fetching objects of type \(name)")
      completion(try ps.ctx.fetch(req))
    } catch {
      log.error("Error while fetching objects of type \(name), reason: \(error.localizedDescription)")
      completion([])
    }
  }
  /// This function fetches the objects from `CoreData` given their type.
  ///
  /// - Parameter type: the object being fetched from `CoreData` of type `T` that is some `NSManagedObject`.
  ///
  /// - Returns: the array of objects for the generic type `T` if successful, otherwise returns an empty array.
  ///
  func fetch<T: NSManagedObject>(_ type: T.Type) -> [T] {
    let (req, name) = fetchRequestFromType(type)
    do {
      return try ps.ctx.fetch(req)
    } catch {
      log.error("Error while retching objects of type \(name), reason: \(error.localizedDescription)")
      return []
    }
  }
  /// This function is responsible for fetching the objects from `CoreData` based on their name.
  ///
  /// - Parameter type: the type `T` which is a generic `NSManagedObject`.
  ///
  /// - Returns: the tuple of `NSFetchRequest<T>` and `String` that represent the object queried.
  ///
  private func fetchRequestFromType<T: NSManagedObject>(_ type: T.Type) -> (NSFetchRequest<T>, String) {
    let name = String(describing: type)
    return (NSFetchRequest<T>(entityName: name), name)
  }
  /// Wrapper to the persistent store save which saves any changes to our context in the database
  ///
  func save() {
    ps.save()
  }
  /// Wrapper to the persistent store flush which wipes the database clean.
  ///
  func flush() {
    ps.flush()
  }
}
