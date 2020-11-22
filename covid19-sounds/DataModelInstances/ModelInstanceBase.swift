//
//  ModelInstanceBase.swift
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

/// The type of operations supported, namely
///
/// - `populate`: fetches the data from `CoreData` and populates the instance.
/// - `save`: saves the instance to `CoreData`.
///
enum OperationType {
  case populate
  case save
}
/// The model protocol that provides the necessary abstraction to handle `CoreData` interaction flexibly;
/// it also attempts to reduce code boilerplate.
///
protocol ModelProtocol {
  /// holds the data service instance.
  var dataService: DataService? { get set }
  /// updates the `CoreData` instance for the type `T` that is some `NSManagedObject`.
  func updateCoreData<T: NSManagedObject>(entity: T, index: Int)
  /// updates the  instance for the type `T` that is some `NSManagedObject`.
  func updateInstance<T: NSManagedObject>(entity: T, index: Int)
  /// process the instance of type `T` that is some `NSManagedObject`.
  func process<T: NSManagedObject>(entityList: [T]?, optype: OperationType, multiple: Bool)
  /// handle both `.save` and `.populate` operation through one place.
  func modelProcessor<T: NSManagedObject>(_ type: T.Type, optype: OperationType, multiple: Bool)
  /// function that is responsible for saving the model to `CoreData` through the generic interface.
  func save()
  /// function that is responsible for populating the instnace from `CoreData` through the generic interface.
  func populate()
}
/// Useful extensions to the `ModelInstance` protocol that provide some default, common methods
/// that can be overriden if need be.
///
extension ModelProtocol {
  /// This is the general model process that through generics it handles both saving and populating supported instances.
  ///
  /// - Parameter type: the `T.type` instance for the entity, usually has the name describing the entity.
  ///
  /// - Parameter optype: the supported operation types of type `OperationType`; currently `.save` and `.populate`.
  ///
  /// - Parameter multiple: supports performing the actions on all instances within `CoreData`.
  ///
  func modelProcessor<T: NSManagedObject>(_ type: T.Type, optype: OperationType, multiple: Bool = false) {
    // check if we have a valid data service instance.
    guard let localDS = dataService else {
      log.error("No valid data service instance set.")
      return
    }
    // get the name describing the entity
    let name = String(describing: type)
    //
    log.info("Processing entity with name: \(name) with optype \(optype)")
    // check if we can find a matching entity
    guard let entityCount = localDS.count(T.self) else {
      log.error("Could not find matching entries in the model with \(name).")
      return
    }
    // the generic entiry array of type T
    var entities: [T]?
    //
    // now check what to do with the entities based on their count and operation type
    if entityCount == 0 {
      if optype == .save {
        log.info("No entity named \(name) found but with zero entries - probably a new installation; creating...")
        // create the object with the default values
        entities = [T(context: localDS.getContext())]
      } else {
        log.warning("Cannot invoke populate with zero entries - skipping.")
        return
      }
    } else {
      log.info("Entity with \(name) name exists with \(entityCount) entries - fetching.")
      // fetch the users
      entities = localDS.fetch(T.self)
    }
    // process the entry
    process(entityList: entities, optype: optype, multiple: multiple)
  }
  /// This is the general process function that through generics it handles both saving and populating supported
  /// instances.
  ///
  /// - Parameter entityList: the `[T]` array instance for the entities which we have to process.
  ///
  /// - Parameter optype: the supported operation types of type `OperationType`; currently `.save` and `.populate`.
  ///
  /// - Parameter multiple: supports performing the actions on all instances within `CoreData`.
  ///
  func process<T: NSManagedObject>(entityList: [T]?, optype: OperationType, multiple: Bool) {
    guard let list = entityList else {
      log.error("Could not unwrap entity list - something bad occurred.")
      return
    }
    //
    // loop through the list
    for (idc, ent) in list.enumerated() {
      // invoke the corresponding function based on the operation we perform
      if optype == .populate {
        updateInstance(entity: ent, index: idc)
      } else if optype == .save {
        updateCoreData(entity: ent, index: idc)
      }
      //
      // if we only process one, break early.
      if !multiple {
        log.info("Processing single entries only, terminating early.")
        break
      }
    }
    // save only if we have save operation.
    if optype == .save {
      // save using the data service
      self.dataService!.save()
    }
  }
}
