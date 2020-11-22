//
//  Token+CoreDataClass.swift
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

/// The class describing the `Token` object which is used to interface with `CoreData`.
///
public class Token: NSManagedObject {

  /// Convenience method to set all properties using one function.
  ///
  /// - Parameter access_token: the value of the access token as `String`
  ///
  /// - Parameter refresh_token: the value of the refresh token as `String`
  ///
  /// - Parameter expires_in: the value of the token expiry date as `Date`
  ///
  /// - Parameter refreshed_at: the value of when the token was refreshed as `Date`
  ///
  func set(access_token: String, refresh_token: String, expires_in: Date, refreshed_at: Date) {
    // set the token
    self.access_token = access_token
    self.refresh_token = refresh_token
    self.expires_in = expires_in
    self.refreshed_at = refreshed_at
  }
}
