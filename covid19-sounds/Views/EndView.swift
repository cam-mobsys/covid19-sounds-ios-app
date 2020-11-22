//
//  StartSymptomSurvey.swift
//  covid19-sounds
//
//  Authors (by order of contribution):
//
//    Andreas Grammenos
//    Api Hastanasombat
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI
import Combine

/// The `View` that is displayed at the end of the survey - due to length it has been segmented
/// to various subviews, which can be seen as independent bits that comprise this.
///
struct EndView: View {
  /// the `UserInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var userInstance: UserInstance
  /// the `AppStatus` instance as an `EnvironmentObject`.
  @EnvironmentObject private var appStatus: AppStatus
  /// shows an alert if we had an error
  @State private var alert = false
  /// the variable that is used to check if we are fetching location or uploading.
  @ObservedObject private var buttonState = uploadButtonState
  //
  /// the `View` body definition.
  var body: some View {
    ZStack {
      //
      VStack {
        //
        if appStatus.appState == .justUploaded {
          //
          EndViewTopTextView().frame(minHeight: 370).onAppear {
            finaliseActions()
          }
          //
          Spacer()
          //
          EndViewBottomTextView()
            .frame(maxHeight: 400)
          //
        } else {
          // normally the state should be either
          // .failed or .failedButCanTryAgain
          //
          EndViewErrorView()
          //
        }
      }
      .modifier(AppBackgroundStyle())
      .disabled(buttonState.loading)
      .blur(radius: buttonState.loading ? 3 : 0)
      //
      ActivityIndicatorView()
      //
    }.alert(isPresented: self.$alert) {
      Alert(title: Text("Error uploading"),
            message: Text(appStatus.getErrorDescription()),
            dismissButton: .default(Text("OK")))
    }
  }
}

/// This function is responsible for saving the final data to the `CoreData` as well as deleting
/// the generated audio files.
///
private func finaliseActions() {
  log.info("Performing the final commit using global data service.")
  ds.save()
  // now try to delete the files
  do {
    log.info("Trying to delete audio files.")
    try FileManager.default.removeItem(at: dailyQuestionnaireInstance.breathingAudio)
    try FileManager.default.removeItem(at: dailyQuestionnaireInstance.coughingAudio)
    try FileManager.default.removeItem(at: dailyQuestionnaireInstance.readingAudio)
    log.info("Removed all audio files successfully.")
  } catch {
    log.error("There was an error while deleting the audio files, reason: \(error)")
  }
}

// only render this in debug mode
#if DEBUG
struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    EndView()
      .environmentObject(debugUserInstance)
      .environmentObject(debugAppStatusInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
