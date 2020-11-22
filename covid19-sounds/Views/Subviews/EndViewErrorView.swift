//
//  EndViewErrorView.swift
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

/// The view that is used to display an error as well as try again for a number of times.
///
struct EndViewErrorView: View {
  /// the `UserInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var userInstance: UserInstance
  /// the `AppStatus` instance as an `EnvironmentObject`.
  @EnvironmentObject private var appStatus: AppStatus
  /// the `UploadButtonState` instance used.
  @ObservedObject private var uploadButton = uploadButtonState
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      //
      Spacer()
      //
      TextViewFactory("endViewErrorText", size: 30, padding: [.vertical, .horizontal])
      //
      Spacer().frame(height: 40)
      //
      if appStatus.appState == .failedButCanTryAgain {
        UploadButtonView()
        //
        Spacer().frame(height: 20)
        //
        //Text("Tried \(uploadButton.tryAgainAttemps) out of \(tryAgainAttempsCutoff) times")
        Text("Tried times \(uploadButton.tryAgainAttemps) \(tryAgainAttempsCutoff)")
        //
      } else {
        EndViewGoToHomeView()
      }
      //
      Spacer()
      //
    }
  }
}

// only render this in debug mode.
#if DEBUG
struct EndViewErrorView_Previews: PreviewProvider {
  static var previews: some View {
    EndViewErrorView()
      .environmentObject(debugUserInstance)
      .environmentObject(debugAppStatusInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
