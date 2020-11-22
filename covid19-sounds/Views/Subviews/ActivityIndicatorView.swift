//
//  ActivityIndicatorView.swift
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

/// This `View` is responsible for showing the activity indicator along with the progrsss
/// made so far depending on the app state. This is only required during upload of the
/// files back to the remote server.
///
struct ActivityIndicatorView: View {
  /// the variable that is used to check if we are fetching location or uploading.
  @ObservedObject private var buttonState = uploadButtonState
  /// the `AppStatus` instance as an `EnvironmentObject`.
  @EnvironmentObject private var appStatus: AppStatus
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      // Activity indicator
      Group {
        VStack {
          if appStatus.appState == .creatingUser {
            Text("Creating User...")
          } else if appStatus.appState == .justRegistered ||
                      appStatus.appState == .registeredButNeedToken {
            Text("Exchanging Token...")
          } else if appStatus.appState == .readyToUpload { //|| appStatus.appState == .justUploaded
            Text("Uploading...")
          } else if appStatus.appState == .failed ||
                      appStatus.appState == .failedButCanTryAgain {
            Text("Unable to upload data!")
              .fontWeight(.semibold)
              .foregroundColor(Color.red)
          } else {
            Text("Loading...")
          }
          ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
      }.opacity(buttonState.loading ? 1: 0)
    }
  }
}
