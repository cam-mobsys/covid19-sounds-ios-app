//
//  ConnectivtyStatus.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import Reachability
import Combine

/// This class is used to monitor the current connectivity status of the app.
///
class ConnectivityStatus: ObservableObject {
  /// private constructor for singleton use.
  private init() {}
  /// singleton instance
  static let shared = ConnectivityStatus()
  /// variable the tracks object changes and sends the appropriate notifications.
  var didChange = PassthroughSubject<Void, Never>()
  /// the `Reachability` instance.
  private var reachability: Reachability?
  /// The variable that tracks the current connectivity status.
  private var connState: NetworkConnectivityState =
    NetworkConnectivityState.none { didSet { didChange.send() } }
  /// Enumeration for having a specific error in
  /// the throw clauses
  ///
  /// - ` reachabilityInitError`: indicates failure to initialise
  ///                            `Reachability`
  ///
  enum ReachabilityError: Error {
    case reachabilityInitError
  }
  /// Enumeration that encapsulates the network connectivity available
  /// currently based on reachability results. Three modes are supported which
  /// are listed below.
  ///
  /// - `cellular`: reachable by Cellular connection
  /// - ` wifi`: reachable by WiFi connection
  /// - ` none`: no network connection.
  ///
  enum NetworkConnectivityState {
    case cellular
    case wifi
    case none
  }
  /// Function that registers the reachability observer
  ///
  func register() {
    do {
      // try to initialise reachability
      try initReachability()
      // register the observer
      addReachabilityObserver()
    } catch {
      log.error("Failed to intialise reachability.")
    }
  }
  /// This function acts as a selector to receive the notifications triggered
  /// for reachability by the observer registered above.
  ///
  /// - Parameter note: the notification triggered by the observer.
  ///
  @objc func reachabilityChanged(note: NSNotification) {
    // convert the generic notification object to a reachability instance
    guard let localReachabilityInstance = note.object as? Reachability else {
      log.error("Failed to cast notification to a Reachability instance.")
      return
    }
    // change the level of connectivity
    switch localReachabilityInstance.connection {
    case .cellular:
      connState = .cellular
      log.info("Reachability level changed to: Cellular.")
    case .wifi:
      connState = .wifi
      log.info("Reachability level changed to: WiFi.")
    case .unavailable:
      log.warning("Reachability level changed to: Unavailable.")
    }
  }
  /// This function checks if we are currently reachable by WiFi.
  ///
  /// - Returns: true if we are reachable by WiFi, false otherwise.
  ///
  func isReachableByWiFi() -> Bool {
    return connState == .wifi
  }
  /// This function check if we are currently connected to the internet
  ///
  /// - Returns: true if we are connect, false otherwise
  ///
  func isReachable() -> Bool {
    return connState != .none
  }
  //
  // MARK: - Private functions
  //
  /// Helper function to initialize reachbility
  ///
  /// - Throws: ReachbilityInitError
  ///
  private func initReachability() throws {
    self.reachability = try? Reachability.init()
    guard self.reachability != nil else {
      throw ReachabilityError.reachabilityInitError
    }
    log.info("Reachability initialized.")
  }
  /// This function adds the reachability observer which is responsible
  /// for registeresting the trigger function once a `reachabilityChanged`
  /// notification is triggered.
  ///
  private func addReachabilityObserver() {
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(reachabilityChanged),
                   name: Notification.Name.reachabilityChanged,
                   object: reachability)
    do {
      try self.reachability!.startNotifier()
    } catch {
      log.error("Could not start reachability notifier, reason: \(error.localizedDescription)")
    }
  }
}
