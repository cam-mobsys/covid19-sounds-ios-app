//
//  AppStatus+States.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation

/// An extension to the `AppStatus` class which conveniently contains all of the state transition
/// helpers within one file.
///
extension AppStatus {
  /// function that transitions the `appState` to the `.initialState` state.
  ///
  func setInitialState() {
    log.verbose("Setting Survey state to: Initial State.")
    self.appState = .initialState
  }
  /// Function that transitions the `appState` to the `.creatingUser` state.
  ///
  func setCreatingUser() {
    log.verbose("Setting Survey state to: Creating User.")
    self.appState = .creatingUser
  }
  /// Function that transitions the `appState` to the `.registeredButNeedToken` state.
  ///
  func setRegisteredButNeedToken() {
    log.verbose("Setting Survey state to: User registered by need Token.")
    self.appState = .registeredButNeedToken
  }
  /// Function that transitions the `appState` to the `.readyToUpload` state.
  ///
  func setReadyToUpload() {
    log.verbose("Setting Survey state to: Ready to Upload.")
    //self.canUploadFlag = true
    self.appState = .readyToUpload
  }
  /// Function that transitions the `appState` to the `.justUploaded` state.
  ///
  func setToJustUploaded() {
    log.verbose("Setting Survey state to: Just Uploaded.")
    // now navigate to HomeView
    self.appState = .justUploaded
  }
  /// Function that transitions the `appState` to the `.justRegistered` state.
  ///
  func setJustRegistered() {
    log.verbose("Setting Survey state to: Just Registered.")
    self.appState = .justRegistered
  }
  /// Function that transitions the `appState` to the `.failed` state.
  ///
  func setFailed(errorType: CurrentAppErrorType = .unspecifiedError) {
    log.error("Setting Survey state to: Failed with error: \(errorType).")
    self.appState = .failed
    self.currentError = errorType
  }
  /// Function that transitions the `appState` to the `.failedButCanTryAgain` state.
  ///
  func setFailedButCanTryAgain(errorType: CurrentAppErrorType = .unspecifiedError) {
    // check if we can try again, which only happens if we tried less times than dictated
    // by the tryAgainAttemptsCutoff variable.
    if uploadButtonState.tryAgainAttemps < tryAgainAttempsCutoff {
      // increase the attemp count
      uploadButtonState.tryAgainAttemps += 1
      log.warning("Although we failed - we can try again; " +
                    "performed \(uploadButtonState.tryAgainAttemps) out of " +
                    "\(tryAgainAttempsCutoff) attemps")
      self.appState = .failedButCanTryAgain
    } else {
      log.error("Setting Survey state to: Failed as max try attempts reched; error was: \(errorType).")
      self.appState = .failed
    }
    // set the provided error type in both cases
    self.currentError = errorType
  }
}
