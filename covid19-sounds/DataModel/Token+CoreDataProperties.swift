//
//  Token+CoreDataProperties.swift
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

/// The `Token` class extensions
///
extension Token {
  /// The fetch request that is used to get all objects of type `Token` from `CoreData` store.
  ///
  /// - Returns: the typed `NSFetchRequest` for the class `Token`.
  ///
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Token> {
    return NSFetchRequest<Token>(entityName: "Token")
  }
  /// The access token value.
  @NSManaged public var access_token: String?
  /// The refresh token value.
  @NSManaged public var refresh_token: String?
  /// The token expiry date.
  @NSManaged public var expires_in: Date?
  /// The last token refresh date.
  @NSManaged public var refreshed_at: Date?
}
