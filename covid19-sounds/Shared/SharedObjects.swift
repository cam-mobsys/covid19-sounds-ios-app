//
//  SharedObjects.swift
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
import SwiftyJSON
import SwiftUI
import Combine

///Wrapper type alias  that is used for any key value stores in order to name named parameters
///
typealias KeyValueTuple = (key: String, value: LocalizedStringKey)

/// Two days constant
let TWO_DAYS: Double = 3600 * 24 * 2

/// Structure that contains the app version and build number which are
/// used for debug purposes.
///
struct AppDetails {
  /// make it a singleton.
  private init() {}
  /// shared instance variable to access the singleton.
  static let shared = AppDetails()
  /// variable that  holds the app version.
  static let appVersion = Bundle
    .main.infoDictionary?["CFBundleShortVersionString"] as? String
  /// variable that holds the app build.
  static let appBuild = Bundle
    .main.infoDictionary?["CFBundleVersion"] as? String
}

/// Structure that contains details about
/// the required server constants; such as
/// endpoint URL and the current device UUID
///
struct ServerDetails {
  /// base server url
  static let baseURL =
    "redacted"
  /// register user register url
  static let userRegistrationURL =
    ServerDetails.baseURL + "/api" + "/create_app_user_preauth/"
  /// password reset url
  static let uploadBinaryURL =
    ServerDetails.baseURL + "/api" + "/receive_file/"
  /// Token fetch/exchange endpoint
  static let tokenURL = ServerDetails.baseURL + "/auth/token/"
  /// the current device UUID
  static let deviceUUID = utils.getDeviceID(prefix: false)
}
