//
//  IntroductionView.swift
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

// initialise _all_ shared variables for debug views
//
// Note that they are _shared_ across the views.
#if DEBUG
/// the initial questionnaire instance.
let debugInitialQuestionnaireInstance = InitialQuestionnaireInstance.shared
/// the daily questionnaire instance.
let debugDailyQuestionnaireInstance = DailyQuestionnaireInstance.shared
/// the user information instance.
let debugUserInstance =  UserInstance.shared
/// the app status instance.
let debugAppStatusInstance = AppStatus.shared
/// the location manager instance.
let debugLocationManagerInstance = LocationManager(singleShotUpdate: true)
/// view locale testing.
let debugLocale = "en"
#endif

/// the audio extension instance.
let audioExt = DailyQuestionnaireInstance.audioFileExtension

/// the stop button fill assert name.
let stopFill = "stop.fill"
/// the recordd (circle) button fill assert name.
let circleFill = "circle.fill"
/// the play button fill assert name.
let playCircle = "play.circle"

/// the minimum allowed duration for a clip.
let durationThreasholdCutoff: Double = 1
/// the max duration for the breatching recording.
let timerStopBreatheThreshold: TimeInterval = 30
/// the max duration for the cough recording.
let timerStopCoughThreshold: TimeInterval = 20
/// the max duration for the reading recording.
let timerStopReadThreshold: TimeInterval = 30
/// the timer stop baseline.
let timerStopThreshold: TimeInterval = 14
/// the try again attemps cutoff before we start over.
let tryAgainAttempsCutoff = 3

/// Vantage point for our application - shows the following, depending on status:
///
///  - if the user has just installed the app they are taken to the `IntroductionLandingTextView`,
///  - if they are recurring, then they are shown the `SymptomsView` which is the start of the daily survey,
///  - finally, if there was an error or have just completed the survey they are shown the `EndView`.
///
struct IntroductionView: View {
  /// the `UserInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var userInstance: UserInstance
  /// the `DailyQuestionnaireInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var dailyQuestionnaireInstance: DailyQuestionnaireInstance

  /// the `View` body definition.
  var body: some View {
    // For some reason this needs to be wrapped in a VStack
    VStack {
      if !self.userInstance.hasUploadedInitial() && !self.userInstance.initialQuestionnaireFilled {
        //
        IntroductionLandingTextView()
        //
      } else {
        // it seems that the we have more than one entry in the initial
        // questionnaire meaning that we have already launched the app.
        //
        // See if user has returned here after completing daily questionnaire
        //
        if userInstance.canSubmitDailyQuestionnaire && !dailyQuestionnaireInstance.dailyQuestionnaireFilled {
          SymptomsView()
            .transition(.move(edge: .trailing))
            .animation(.default)
        } else {
          // otherwise, direct the user to the end view
          EndView()
            .transition(.move(edge: .trailing))
            .animation(.default)
        }
      }
      //
    }
    .onReceive(NotificationCenter
                .default
                .publisher(for: UIApplication.willEnterForegroundNotification),
               perform: { _ in
                log.info("App entering in foreground")
                self.userInstance.populate()
               })
  }
}

// only enable preview in debug mode
#if DEBUG
struct IntroductionView_Previews: PreviewProvider {
  static var previews: some View {
    return IntroductionView()
      .environmentObject(debugUserInstance)
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
