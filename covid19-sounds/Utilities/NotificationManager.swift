//
//  notifCenterDelegate.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import Combine
import UserNotifications

/// The notification manager class which is used to handle, register, and schedule the notifications.
///
class NotificationManager: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
  /// shared notification manager instance.
  static let shared = NotificationManager()
  #if DEBUG
  /// Number of seconds between notifications in debug mode.
  static let notificationIntervalSeconds: Double = 10 * 60
  #else
  /// Number of seconds between notifications.
  static let notificationIntervalSeconds: Double = 3600 * 24 * 2
  #endif
  let objectWillChange = ObservableObjectPublisher()
  /// Check if notifications are enabled - note that this property has to be explicitly posted on the main thread.
  var notificationAuthorisation: UNAuthorizationStatus = .denied {
    didSet { DispatchQueue.main.async { self.objectWillChange.send() } }
  }
  // do it as a singleton
  private override init() { super.init() }
  /// This function determines what to do when the user responds to a previously set notification
  ///
  /// - Parameter center: the notification center instance of type `UNUserNotificationCenter`.
  ///
  /// - Parameter response: the response of type `UNNotificationResponse`.
  ///
  /// - Parameter completionHandler: the completion handler to run.
  ///
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    // How to respond to user navigation with notification
    if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
      log.info("Open app from notification")
      handleNotification()
    } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
      log.info("Notification Dismissed")
      handleNotification()
    } else {
      log.error("Unknown notification action")
    }
    // invoke the completion handler
    completionHandler()
  }
  /// This function is responsible to gauge if the user has authorised the use of notifications
  ///
  public func areNotificationsEnabled() {
    UNUserNotificationCenter
      .current()
      .getNotificationSettings(completionHandler: { settings in
      self.notificationAuthorisation = settings.authorizationStatus
    })
  }
  /// This function is responsible for registering the notifications that the user will have to see. We only
  /// register the observer automatically if we are already authorized unless the `register` argument
  ///  is `true`, in which case we prompt the user to allow the notifications.
  ///
  /// - Parameter register: a `Bool` flag that sets if we want to register the observer or not.
  ///
  public func registerNotificationObserver(register: Bool = false) {
    log.info("Attempting to register the notification observer.")
    // grab the current notification center settings
    UNUserNotificationCenter
      .current()
      .getNotificationSettings(completionHandler: { settings in
      // set the notification status
      DispatchQueue.main.async {
        self.notificationAuthorisation = settings.authorizationStatus
        if settings.authorizationStatus == .authorized {
          log.info("Notifications are authorised")
          self.requestObserverRegistration()
        } else if settings.authorizationStatus == .notDetermined {
          log.warning("User has not selected any notification status yet")
          if register {
            log.info("Register flag is up - registering")
            self.requestObserverRegistration()
          }
        } else if settings.authorizationStatus == .denied {
          log.warning("Notifications are not authorised")
          self.notificationAuthorisation = .denied
        } else {
          log.warning("Provisional or ephemeral notification ")
          self.requestObserverRegistration()
        }
      }
    })
  }
  /// This function is responsible for registering the notification observer by request. If the notifications
  /// are already allows it just registers the observer, however if the notifications are _not_ yet authorised
  /// or denied the request is delegated to the end of the survey.
  ///
  func requestObserverRegistration() {
    // fetch current instance of the notification center
    let notificatonCenter = UNUserNotificationCenter.current()
    // assign the class to the notification center delegate
    notificatonCenter.delegate = NotificationManager.shared
    // register notification types and actions
    let action = UNNotificationAction(identifier: UNNotificationDismissActionIdentifier,
                                      title: "Dismiss",
                                      options: [])
    // setup the category - we only require one
    let category = UNNotificationCategory(identifier: "dismissCategory",
                                          actions: [action],
                                          intentIdentifiers: [],
                                          options: .customDismissAction)
    // set the notification categories
    notificatonCenter.setNotificationCategories([category])
    //
    // Request permission to display notifications
    notificatonCenter
      .requestAuthorization(options: [.alert, .sound],
                            completionHandler: { (granted, err) in
      if granted {
        log.info("Notification Authorisation probe was successful - status: \(granted)")
        log.info("Notification observer registered successfully - setting nofications to be enabled.")
        self.notificationAuthorisation = .authorized
      } else {
        log.error("Notification authorisation probe was unsuccessfull - reason: \(err.debugDescription)")
        log.info("Setting nofications to be denied")
        self.notificationAuthorisation = .denied
      }
    })
  }
  /// Set a notification every x days
  ///
  /// - Parameter `interval`: the interval between the notifications in seconds.
  ///
  /// - Parameter `completionHandler`: the completion handler which is called after successful execution.
  ///
  func scheduleNotification(interval: Double = NotificationManager.notificationIntervalSeconds,
                            completionHandler: (() -> Void)? = nil) {
    // Create the content of the notification
    let content = createNotificationContent()
    // Create the trigger condition for the notification
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
    // Create the notification request
    let request = UNNotificationRequest(identifier: "default", content: content, trigger: trigger)
    // Ask the OS for the notification to be scheduled
    registerNotification(request, handler: completionHandler)
  }
  /// Create message that will be dosplayed to the user upon notification
  ///
  /// - Returns: returns the `UNMutableNotificationContent` which contains the notification content to display
  ///
  func createNotificationContent() -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "How are you feeling?".localized()
    content.body = "Take a moment to complete a brief assessment".localized()
    content.sound = UNNotificationSound.default
    content.categoryIdentifier = "dismissCategory"
    return content
  }
  /// Request the OS for a notification to be scheduled
  ///
  /// - Parameter notificationReqquest: the `UNNotificationRequest` to be registered,
  ///
  /// - Parameter handler: the handler to call once the notification is fired.
  ///
  func registerNotification(_ notificationRequest: UNNotificationRequest,
                            handler: (() -> Void)? = nil) {
    let notifCenter = UNUserNotificationCenter.current()
    notifCenter.add(notificationRequest) { (error) in
      if error != nil {
        // Handle any errors.
        log.error("Unable to Schedule Notification: \(String(describing: error))")
      } else {
        log.info("Notification registered using notification interval of: " +
                  "\(NotificationManager.notificationIntervalSeconds) seconds.")
        (handler ?? {
          log.error("No registerNotification Handler Invoked")
        }) ()
      }
    }
  }
  /// Check if scheduled notifications are the same duration as notificationIntervalDays
  /// If not, resets them
  ///
  /// - Parameter handler: the optional handler to call if  the notification needs to be scheduled.
  ///
  func checkNotificationSettings(handler: (() -> Void)? = nil) {
    UNUserNotificationCenter
      .current()
      .getPendingNotificationRequests(completionHandler: { requests in
        // check if the notification requests are empty
        if requests.isEmpty {
          log.info("No notifications set")
        } else if requests.count == 1 {
          // Need to force convert the trigger check time
          guard let trigger = requests[0].trigger as? UNTimeIntervalNotificationTrigger else {
            log.error("Could not cast the request object to UNTimeIntervalNotificationTrigger - cannot proceed.")
            return
          }
          //
          if trigger.timeInterval == NotificationManager.notificationIntervalSeconds {
            log.info("Notification interval of \(trigger.timeInterval) seconds is same as " +
                      "notificationIntervalSeconds which is: \(NotificationManager.notificationIntervalSeconds) ")
          } else {
            log.warning("Notification interval of \(trigger.timeInterval) is different to  " +
                          "notificationIntervalSeconds which is " +
                          "\(NotificationManager.notificationIntervalSeconds) - updating its value",
                        context: {
                          // Notifications previously set, reset with new interval
                          if appStatus.notificationsSet {
                            self.scheduleNotification(interval: NotificationManager.notificationIntervalSeconds,
                                                      completionHandler: handler)
                          } else {
                            // Something went wrong
                            log.error("Invalid notification state")
                          }
                        })
          }
          //
        } else {
          // handle the case of too many registered notification - in this case we remove all and re-register them.
          log.warning("Too many notifications, removing all and scheduling new one")
          UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
          if appStatus.notificationsSet {
            self.scheduleNotification(interval: NotificationManager.notificationIntervalSeconds,
                                      completionHandler: {})
          } else {
            log.error("Invalid notification state")
          }
        }
    })
  }
  /// Check whether notifications are scheduled when user interacts with a previous notification and if not, sets it
  ///
  /// Currently not implemented,
  ///
  func handleNotification() {
    log.info("Notification handler invoked.")
    return
  }
}
