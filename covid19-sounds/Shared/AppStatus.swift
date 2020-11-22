//
//  AppState.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// The internal error states
///
/// - `networkError`: indicates a network error occurred.
/// - `internalError`: internel app error.
/// - `registrationError`: registration error.
/// - `tokenError`: token related error.
/// - `uploadSuccess`: the upload was successful.
/// - `noError`: no error currently.
///
enum CurrentAppErrorType {
  case
  networkError,
  internalError,
  registrationError,
  tokenError,
  uploadError,
  receivedDataError,
  unspecifiedError,
  noError
}

/// Enumeration that holds the survey progress
///
/// - `initialState`: the initial state of the app
/// - `creatingUser`: creating user status
/// - `justRegistered`: when we have just recevied user credentials from the server
/// ` `registeredButNeedToken`: when we have registered but not exchanged the OAuth token
/// - `readyToUpload`: when we are ready to upload the files
/// - `justUpladed`: when we have just uploaded the payload
/// - `failed`: an error was occurred during execution
///
enum SurveyProgressStates {
  case
  initialState,
  creatingUser,
  justRegistered,
  registeredButNeedToken,
  readyToUpload,
  justUploaded,
  failedButCanTryAgain,
  failed
}

/// Class that is responsible for reflecting the error status of the app
///
class AppStatus: ObservableObject {
  /// shared instance variable to access the singleton.
  static let shared = AppStatus()
  /// variable the tracks object changes and sends the appropriate notifications.
  var didChange = PassthroughSubject<Void, Never>()
  /// Flag for whether the user has registered by submitting at least once.
  @Published var appState: SurveyProgressStates = .initialState {
    didSet { handleStateTransitions(user: userInstance) }
  }
  /// the current internal error representation
  @Published var currentError: CurrentAppErrorType = .noError {
    didSet { didChange.send() }
  }
  /// Variable that triggers alert in `EndView`.
  @Published var alert: Bool = false
  /// holds whether recurring notifications have been set
  var notificationsSet = false
  /// do it as asingleton
  private init() {}
  /// private variable that prevents acting on events
  private var canUploadFlag: Bool = false

  /// This function retrieves the error message description based on the
  /// current `AppStatus` state.
  ///
  /// - Returns: the error description based on `AppStates`.
  ///
  func getErrorDescription() -> LocalizedStringKey {
    switch currentError {
    case .networkError:
      return "Network error occurred, please ensure internet access."
    case .internalError:
      return "Internal error occurred, please contact support."
    case .registrationError:
      return "Error occurred during registration, ensure network connectivity."
    case .tokenError:
      return "Error occurred during token exchange, ensure network connectivity."
    case .uploadError:
      return "Error during data upload."
    case .receivedDataError:
      return "Received invalid data."
    case .unspecifiedError:
      return "An unspecified error occurred."
    case .noError:
      return "No error."
    }
  }
  //
  // MARK: - Handle user status change
  //
  /// This function is responsible for handling the state of the user creation, including the authorisation
  /// (i.e.: the token exchange process).
  ///
  func handleUserStatus() {
    log.info("Handling state: \(appState)")
    if appState == .initialState {
      setCreatingUser()
    } else if appState == .registeredButNeedToken {
      setRegisteredButNeedToken()
    } else if appState == .failedButCanTryAgain {
      setCreatingUser()
    } else {
      log.error("Unexpected state: \(appState).")
      setFailedButCanTryAgain(errorType: .unspecifiedError)
    }
  }
  //
  // MARK: - Manage app state transition
  //
  /// This function handles the state transitions within the app
  ///
  /// - Parameter user: the `UserInstance` variable used to extract the user information.
  ///
  private func handleStateTransitions(user: UserInstance) {
    // notify the observer
    didChange.send()
    // log the registration status
    log.info("App state changed - current state \(appState)")
    //
    // check if we can upload
    if !canUpload() && appState != .justUploaded { return }
    //
    // now perform the appropriate action based on current state
    //
    switch appState {
    case .initialState:
      log.info("App is in initial state.")
    case .creatingUser:
      log.info("Creating user state entered.")
      if user.username.isEmpty {
        log.info("User seem be empty, need to create.")
        netManager.createUser(completionHandler: self.setJustRegistered)
      } else {
        log.info("User seem to exist with username: \(user.username) - skipping creation.")
        self.setJustRegistered()
      }
    case .justRegistered:
      log.info("User has just registered.")
      netManager.tokenExchange(completionHandler: self.setReadyToUpload)
    case .registeredButNeedToken:
      log.info("User has registered but needs token.")
      netManager.tokenExchange(completionHandler: self.setReadyToUpload)
    case .readyToUpload:
      log.info("Ready to upload.")
      // we reached the end
      raiseCanUploadFlag()
      // upload files
      netManager.uploadFiles()
    case .justUploaded:
      log.info("Just Uploaded - updating stored entity.")
      // save the details
      user.save()
      ds.save()
      // disable the flag for submitting the daily questionnaire
      user.canSubmitDailyQuestionnaire = false
      // disable loading
      uploadButtonState.loading = false
    case .failedButCanTryAgain:
      log.error("User registration or upload failed - but can try again.")
      // enable that the questionnaire is filled so we can retain the data
      dailyQuestionnaireInstance.dailyQuestionnaireFilled = true
      // disable loading
      uploadButtonState.loading = false
    case .failed:
      log.error("User registration or upload failed")
      dailyQuestionnaireInstance.dailyQuestionnaireFilled = true
      // disable loading
      uploadButtonState.loading = false
    }
  }
  //
  // MARK: Misc functions
  //
  /// The `canUpload` function is responsible for checking if we can indeed upload.
  ///
  /// - Parameter raiseFlag: optional argument to raise the `canUploadFlag` if needed.
  ///
  /// - Returns: `true` if we can upload and have internet connectivity, `false` otherwise.
  ///
  func canUpload(raiseFlag: Bool = false) -> Bool {
    // handle no connectivity
    if !connStatus.isReachable() {
      log.error("Not connected to internet - cannot do much.")
      return false
    } else if appState == .justUploaded {
      log.warning("Just ust uploaded, but checking the delta is we need again")
      return false
    } else if !canUploadFlag && !raiseFlag {
      log.error("Not able to upload yet - we need to reach the end fist.")
      return false
    } else {
      log.info("We have internet connectivity & can upload.")
      canUploadFlag = true
      return true
    }
  }
  /// Function that raises the `canUploadFlag` regardless of value; it is used for the state transitions.
  ///
  func raiseCanUploadFlag() {
    canUploadFlag = true
  }
}
