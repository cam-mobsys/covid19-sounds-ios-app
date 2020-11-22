//
//  AuthenticationUtilities.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos (main contributor)
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

/// This class contains all of the authentication/authorisation utilities
/// used by this app.
///
class AuthenticationUtilities {
  /// make it a singleton
  private init() {}
  /// the static access member for the singleton
  static let shared = AuthenticationUtilities()
  /// predefined user key mail
  private let userKeyMail = "redacted"
  /// predefined user key password
  private let userKeyPass = "redacted"
  /// This function is responsible for creaing a user provided a username, password, and
  /// email.
  ///
  /// - Parameter username: the potential username
  ///
  /// - Returns: the `DataRequest` object
  ///
  func createUserRequest() -> DataRequest {
    // return the populated request
    return AF.request(ServerDetails.userRegistrationURL,
                      method: .post,
                      parameters: self.createUserParameters(),
                      encoding: URLEncoding(),
                      headers: nil)
  }
  /// This function constructs and multipart upload requesting using the parameter dictionary provided.
  ///
  /// - Parameter `params`: the parameter dictionary to pass into the multipart form
  ///
  /// - Returns: the populated `UploadRequest` instance.
  ///
  private func buildUploadFromDict(params: [String: String]) -> UploadRequest {
    // construct the request
    return AF.upload(multipartFormData: { multipartFormData in
      for(key, val) in params {
        multipartFormData.append(val.data(using: .utf8)!, withName: key)
      }
    }, to: ServerDetails.tokenURL, method: .post, headers: nil)
  }
  /// This function creates an exchange token upload request.
  ///
  /// - Returns:the refresh token upload request.
  ///
  func accessTokenRequest() -> UploadRequest {
    return buildUploadFromDict(params: self.exchangeTokenUserParameters())
  }

  /// This function creates a refresh token upload request.
  ///
  /// - Returns:the refresh token upload request.
  ///
  func refreshTokenRequest() -> UploadRequest {
    return buildUploadFromDict(params: self.refreshTokenParameters())
  }
  /// This function prepares the alamofire parameters for creating the user; the required
  /// parameters are the username, password, and email.
  ///
  /// - Parameter username: the username for creating the user
  ///
  /// - Returns: create user parameter dictionary
  ///
  func createUserParameters(username: String,
                            password: String,
                            email: String) -> [String: String] {
    // This function generates the parameters for the Alamofire requet
    return ["username": username,
            "password": password,
            "email": email]
  }
  /// This function prepares the alamofire parameters for exchaning the user
  /// credential for a OAuth2 token from our provider.
  ///
  /// - Returns: exchange token parameter dictionary
  ///
  func exchangeTokenUserParameters() -> [String: String] {
    return ["username": userInstance.username,
            "password": userInstance.password,
            "client_id": oauth.clientID,
            "client_secret": oauth.clientSecret,
            "grant_type": oauth.grantTypeExchange]
  }
  /// This function prepares the alamofire parameters for refreshing the user
  /// token for a new OAuth2 token from our provider.
  ///
  /// - Returns: refresh token parameter dictionary
  ///
  func refreshTokenParameters() -> [String: String] {

    return ["client_id": oauth.clientID,
            "client_secret": oauth.clientSecret,
            "grant_type": oauth.grantTypeRefresh,
            "refresh_token": oauth.refreshToken]
  }
  /// This function constructs the parameter dictionary for user creation
  ///
  /// - Returns: create user parameter dictionary
  ///
  private func createUserParameters() -> Parameters {
    return [
      "username": utils.randomString(),
      "password": self.userKeyPass,
      "email": self.userKeyMail
    ]
  }
  /// This function checks if we have populated the username and password for the
  /// current user.
  ///
  /// - Returns: `true` is we can exchange the token, `false` otherwise.
  ///
  func canExchangeToken() -> Bool {
    return !(utils.isEmptyString(str: userInstance.username) &&
      utils.isEmptyString(str: userInstance.password))
  }
  /// This function checks if we currently have an access token in the `OAuthInfo` struct
  ///
  ///- Returns: `true` if the refresh token is non empty, `false` otherwise.
  ///
  func haveAccessToken() -> Bool {
    return !utils.isEmptyString(str: oauth.accessToken)
  }
  /// This function checks if we currently have a refresh token in the `OAuthInfo` struct
  ///
  ///- Returns: `true` if the refresh token is non empty, `false` otherwise.
  ///
  func haveRefreshToken() -> Bool {
    return !utils.isEmptyString(str: oauth.refreshToken)
  }
}
