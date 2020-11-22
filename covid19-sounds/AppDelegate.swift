//
//  AppDelegate.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import UIKit
import CoreData
import SwiftyBeaver

/// our log utility (Swiftybeaver) instance
let log = SwiftyBeaver.self
// swifty beaver configuration

// register for console logs
let console = ConsoleDestination()

// cloud swiftybeaver stuff
let useCloudLogs = false
let swiftyAppID = "redacted"
let swiftyAppSecret = "redacted"
let swiftyEncryptionKey = "redacted"
let cloud = SBPlatformDestination(
  appID: swiftyAppID,
  appSecret: swiftyAppSecret,
  encryptionKey: swiftyEncryptionKey)

/// our connectivity status instance.
let connStatus = ConnectivityStatus.shared
/// authentication utilities.
let authUtils = AuthenticationUtilities.shared
/// generic convenience utilities.
let utils = Utilities.shared

/// holds the OAuth singleton.
let oauth = OAuthInfo.shared
/// the user info instance (holds username, password) - must be attempted to be loaded from CoreData.
let userInstance = UserInstance.shared
/// holds the daily questionnaire instance replies.
let dailyQuestionnaireInstance = DailyQuestionnaireInstance.shared
/// holds the initial questionnaire instance replies - must be attempted to be  loaded from CoreData.
let initialQuestionnaireInstance = InitialQuestionnaireInstance.shared
/// holds the location manager instance which is used to get the location.
let locManager = LocationManager(singleShotUpdate: true)
/// holds the network manager instance which is used to upload our data.
let netManager = NetworkManager.shared
/// holds the current app status.
let appStatus = AppStatus.shared
/// holds the data model service.
let ds = DataService.shared
/// holds the notification manager instance.
let notificationManager = NotificationManager.shared

// entry type based on run.
#if DEBUG
  /// entry type for testing.
  let entryType = "testing-entry"
#else
  /// entry type for production.
  let entryType = "production-entry"
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  //
  // MARK: - App initialisation
  //
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // default log enabled
    log.addDestination(console)
    #if DEBUG
    log.info("Can attach cloud console - DEBUG mode.")
    // add cloud logs, if enabled
    if useCloudLogs {
      log.info("Cloud logs enabled - attaching cloud console.")
      log.addDestination(cloud)
    } else {
      log.warning("Cloud logs disabled - not attaching cloud console.")
    }
    #endif
    log.info("App started.")
    //
    // see explicitly which vantage point we are currently using.
    log.verbose("Using vantage point: \(ServerDetails.baseURL)")
    //
    // uncomment to flush the db, if needed.
    //ds.flush()
    //
    // set data service
    oauth.dataService = ds
    userInstance.dataService = ds
    //
    // populate the user entity
    userInstance.populate()
    // populate the oauth details
    oauth.populate()
    // start reachability
    connStatus.register()
    // gauge the status of the notifications
    notificationManager.registerNotificationObserver()
    // finally, return
    return true
  }
  //
  // MARK: UISceneSession Lifecycle
  //
  func application(_ application: UIApplication,
                   configurationForConnecting connectingSceneSession: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration",
                                sessionRole: connectingSceneSession.role)
  }
  //
  func application(_ application: UIApplication,
                   didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // empty
  }
  //
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application will terminate - this ensures that our current changes are saved.
  }
}
