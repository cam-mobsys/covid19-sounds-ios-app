//
//  User+CoreDataProperties.swift
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

/// The `User` class extensions
///
extension User {
  /// The fetch request that is used to get all objects of type `User` from `CoreData` store.
  ///
  /// - Returns: the typed `NSFetchRequest` for the class `User`.
  ///
  @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
    return NSFetchRequest<User>(entityName: "User")
  }
  /// the optional uploaded initial date value
  @NSManaged public var uploaded_initial: Date?
  /// the optional last completed date of the survey
  @NSManaged public var last_completed: Date?
  /// the optional user password
  @NSManaged public var password: String?
  /// the optional username
  @NSManaged public var username: String?
}
