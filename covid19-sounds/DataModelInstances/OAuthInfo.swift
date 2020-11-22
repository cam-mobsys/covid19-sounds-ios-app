//
//  OAuthInfo.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

/// Structure which keeps all of the OAuth related variables/properties
///
class OAuthInfo: ModelProtocol {
  /// the (optional) data service of type `DataService`
  var dataService: DataService?
  /// shared object for singleton
  static let shared = OAuthInfo()
  /// private constructor to be a singleton
  private init() {}
  /// this is the client secret used for the OAuth application.
  let clientSecret = "redacted"
  /// this is the client ID used for the OAuth application
  let clientID = "redacted"
  /// grant type when fetching the token for the first type
  let grantTypeExchange = "password"
  /// grant type when refreshing the token subsequently
  let grantTypeRefresh = "refresh_token"
  /// the token type
  let tokenType = "Bearer"
  /// when the token was refreshed
  var refreshedAt: Date?
  /// check when the token expires
  var expiresIn: Date?
  /// stored user token
  var accessToken = ""
  /// stored user refresh token
  var refreshToken = ""
  //
  // MARK: - General functionality
  //
  /// This function is responsible for generating the Alamofire header used for backend authorisation.
  ///
  /// - Returns: the populated `HTTPHeaders` array.
  ///
  func getAuthorisationHeader() -> HTTPHeaders {
    return ["Authorization": "\(self.tokenType) \(self.accessToken)"]
  }
  //
  // MARK: - CoreData protocol implementation
  //
  /// This function is responsible for updating the `CoreData` stored entities of type `T` which is in this case
  /// `Token`.
  ///
  /// - Parameter entity: the parameter `T` which is `Token` in this instance.
  ///
  /// - Parameter index: the index of the parameter to update, we get the first one by default.
  ///
  func updateCoreData<T>(entity: T, index: Int = 0) where T: NSManagedObject {
    // cast entity to token, if possible other wise return and log the error
    guard let token = entity as? Token else {
      log.error("Failed to type cast the enity to Token - cannot proceed")
      return
    }
    log.info("Attempting to update the token model.")
    // check if we have a completed time, if not report and return.
    guard
      let refreshedAt = self.refreshedAt,
      let expiresIn = self.expiresIn else {
        log.error("Attempting to save without having a valid refreshed at or expires in.")
        return
    }
    // set the token
    token.set(access_token: self.accessToken,
              refresh_token: self.refreshToken,
              expires_in: expiresIn,
              refreshed_at: refreshedAt)
    return
  }
  /// This function is responsible for updating the current `OAuthInfo` from `CoreData` fetched
  /// entities of type `T` which is in this case`Token`.
  ///
  /// - Parameter entity: the parameter `T` which is `Token` in this instance.
  ///
  /// - Parameter index: the index of the parameter to update, we get the first one by default.
  ///
  func updateInstance<T>(entity: T, index: Int = 0) where T: NSManagedObject {
    // cast entity to token, if possible other wise return and log the error
    guard let token = entity as? Token else {
      log.error("Failed to type cast the enity to Token - cannot proceed")
      return
    }
    // update the token parameters based on the converted entity
    guard
      let accessToken = token.access_token,
      let refreshToken = token.refresh_token,
      let expiresIn = token.expires_in,
      let refreshedAt = token.refreshed_at
      else {
        log.error("Values that should be non-nil they are - this unexpected.")
        return
    }
    // now set them
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.refreshedAt = refreshedAt
    self.expiresIn = expiresIn
    // finally return
    return
  }
  /// Function that is responsible for saving the `Token` values to `CoreData`
  ///
  func save() {
    modelProcessor(Token.self, optype: .save)
  }
  /// Function that is responsible for populating the `Token` values from `CoreData`
  ///
  func populate() {
    modelProcessor(Token.self, optype: .populate)
  }
}
