//
//  UploadButtonView.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import CoreLocation
import SwiftUI

/// This helper class is responsible for storing the `loading` boolean variable which indicates
/// if the screen needs to be blurred; and the location `fireCounter` which counts the number of
/// attemps to get a location. Finally, we include a flag to show if we are trying again or not.
///
class UploadButtonState: ObservableObject {
  /// the flag that shows the activity indicator
  @Published var loading: Bool = false
  /// the number of location counts
  @Published var fireCounter: Int = 1
  /// the number of attempts performed.
  @Published var tryAgainAttemps: Int = 0
}

// var attCount = 1

/// the location attemps cutoff
let locationAttempCutoff = 5

/// used to save the `UploadButtonState` so that other views can listen to updates.
var uploadButtonState = UploadButtonState()

/// This button is responsible for uploading the gathered data, registering the notifications as well as
/// collecting the location sample.
///
struct UploadButtonView: View {
  /// the `UserInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var userInstance: UserInstance
  /// the `AppStatus` instance as an `EnvironmentObject`.
  @EnvironmentObject private var appStatus: AppStatus
  /// the `LocationManager` instance as an `EnvironmentObject`.
  @EnvironmentObject private var locationManager: LocationManager
  /// the variable that is used to check if we are fetching location or uploading.
  @ObservedObject private var buttonState = uploadButtonState
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      //
      Button {
        log.info("Next button tapped in LocationView")
        //
        // reset the location fire counterfin
        buttonState.fireCounter = 1
        //
        // handle the upload of files
        handleUpload(user: userInstance,
                     app: appStatus,
                     loc: locationManager,
                     buttonState: buttonState)
//
//        if attCount == 1 {
//          attCount += 1
//          appStatus.setFailedButCanTryAgain(errorType: .networkError)
//          dailyQuestionnaireInstance.dailyQuestionnaireFilled = true
//          return
//        }
//
        // handle the location gathering
        handleLocationGathering(loc: locationManager,
                                app: appStatus,
                                buttonState: buttonState)
        //
        // schedule notifications
        scheduleNotifications(app: appStatus)
      } label: {
        //if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
        if locationManager.accessNotDetermined() {
          HStack {
            Text("Set Permissions")
              .font(.custom("Next", size: 23))
          }
        } else {
          if appStatus.appState == .failedButCanTryAgain {
            HStack {
              Text("Try again")
                .font(.custom("Next", size: 23))
            }
          } else {
            HStack {
              Text("Next")
                .font(.custom("Next", size: 23))
            }
          }
        }
      }
      .buttonStyle(GradientBackgroundStyle())
      .onAppear(perform: {
        //log.info("Setting can submit to false")
      })
    }
  }
}

// MARK: - Helper functions

/// This function is responsible for uploading the files, note that this functio needs to be called
/// _before_ the location handler as this registeres the location handler function to be executed.
///
/// - Parameter user: the `UserInstance` used for saving the location.
///
/// - Parameter app: the `AppStatus` instance used to check or set the app status.
///
/// - Parameter loc: the `LocationManaged` instance to use.
///
/// - Parameter buttonState: the `UploadButtonState` isntance used.
///
private func handleUpload(user: UserInstance,
                          app: AppStatus,
                          loc: LocationManager,
                          buttonState: UploadButtonState) {
  // tag the completed measurement time
  user.setCompletedTime()
  // reset the fire counter
  buttonState.fireCounter = 1
  //
  log.info("app state is: \(app.appState)")
  //
  // Check if there is connectivity, if not, don't bother
  if app.canUpload(raiseFlag: true) {
    // set location handler, will only run if permission allowed
    // Also need access to view scope
    loc.setLocationHandler(locationHandler: {
      // run the timer every 1 second to check if we have a location update
      Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
        log.info("Timer fired \(buttonState.fireCounter) time(s) so far.")
        // assign the location we got currently
        dailyQuestionnaireInstance.location = loc.locationToString()
        //
        // check if we have a valid location yet, otherwise we
        // give up after waiting about 5 seconds
        if loc.haveValidLocation() {
          log.info("We received a valid location - \(loc).")
          timer.invalidate()
          // now handle user status
          buttonState.loading = true
          app.handleUserStatus()
        } else if buttonState.fireCounter > locationAttempCutoff {
          log.error("Gave up on location after trying \(buttonState.fireCounter) times")
          timer.invalidate()
          // now handle the user status
          buttonState.loading = true
          app.handleUserStatus()
        } else {
          log.warning("Could not get location at probe no: \(buttonState.fireCounter)" +
              " - waiting \(locationAttempCutoff - buttonState.fireCounter) more times")
          buttonState.fireCounter += 1
        }
        //
      })
    })
    //
  } else {
    app.setFailedButCanTryAgain(errorType: .networkError)
    dailyQuestionnaireInstance.dailyQuestionnaireFilled = true
  }
}

/// This function is responsible for handling the location gathering.
///
/// - Parameter loc: the instace of `LocationManager` to use for gathering.
///
/// - Parameter app: the instance of `AppStatus` for state transitions.
///
/// - Parameter buttonState: the `UploadButtonState` isntance used.
///
private func handleLocationGathering(loc: LocationManager,
                                     app: AppStatus,
                                     buttonState: UploadButtonState) {
  // check if we can upload and if not, then just return
  if !app.canUpload() {
    log.warning("Cannot upload - no need to gather location")
    return
  }
  //
  // Handle the different authorisation statuses
  switch CLLocationManager.authorizationStatus() {
  // No permission status available
  case .notDetermined:
    log.info("No permission available, requesting..")
    loc.requestWhenInUseAuthorization()
  // Permission denied, do nothing and navigate
  case .restricted, .denied:
    log.info("Permission previously denied, navigating to HomeView")
    buttonState.loading = true
    app.handleUserStatus()
  // Previously allowed, proceed to get location
  case .authorizedAlways, .authorizedWhenInUse:
    log.info("Permission authorised, start location services")
    loc.startTrackingLocation()
  // Unknown status, maybe from future updates
  @unknown default:
    log.warning("Unknown location permission status")
  }
}

/// This function is responsible for scheduling the notifications
///
/// - Parameter app: the instance of `AppStatus` for state transitions.
///
private func scheduleNotifications(app: AppStatus) {
  // check if we can upload - if not, no need to schedule notifications
  if !app.canUpload() {
    log.warning("Cannot upload - no need to schedule notifications")
    return
  }
  //
  // Schedule reminder to come back to survey if not done already
  if !app.notificationsSet {
    log.info("Notifications not set, requesting...")
    notificationManager
      .scheduleNotification(completionHandler: {
                              log.info("Setting userInstance.notificationsSet to true")
                              app.notificationsSet = true
                            })
  }
}

// only show this in debug view
#if DEBUG
struct UploadButtonView_Previews: PreviewProvider {
  static var previews: some View {
      UploadButtonView()
        .environmentObject(debugLocationManagerInstance)
        .environmentObject(debugUserInstance)
        .environmentObject(debugAppStatusInstance)
        .environmentObject(debugLocationManagerInstance)
        .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
