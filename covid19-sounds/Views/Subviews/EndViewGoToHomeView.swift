//
//  EndViewGoToHomeView.swift
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

/// This `View` is reponsible to go from the `EnvView` back to the `IntroductionView` to start over.
///
struct EndViewGoToHomeView: View {
  /// the `UserInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var userInstance: UserInstance
  /// the `AppStatus` instance as an `EnvironmentObject`.
  @EnvironmentObject private var appStatus: AppStatus
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      Button {
        // go to initial
        userInstance.canSubmitDailyQuestionnaire = true
        log.info("userInstance.canSubmitDailyQuestionnaire set to " +
                  "\(userInstance.canSubmitDailyQuestionnaire)")
        //
        dailyQuestionnaireInstance.dailyQuestionnaireFilled = false
        log.info("dailyQuestionnaireInstance.dailyQuestionnaireFilled set to " +
                  "\(dailyQuestionnaireInstance.dailyQuestionnaireFilled)")
        //
        // check if it's the first time doing the questionnaire; if it is
        // then this should be true when we arrive here and thus in case of
        // failure we should set the initial questionnaire filled to false,
        // even if true.
        //
        // This is the case as the "try again" should restart the whole process
        // from where it started before.
        //
        if !userInstance.hasUploadedInitial() {
          userInstance.initialQuestionnaireFilled = false
        }
        // set the app state to be back to the initial state.
        appStatus.setInitialState()
        log.info("appStatus.appState set to \(self.appStatus.appState)")
        //
      } label: {
        //
        Text("Start over").font(.custom("Next", size: 23))
        //
      }.buttonStyle(GradientBackgroundStyle())
    }
  }
}

// only render this in debug mode.
#if DEBUG
struct EndViewGoToHomeView_Previews: PreviewProvider {
  static var previews: some View {
    EndViewGoToHomeView()
      .environmentObject(debugUserInstance)
      .environmentObject(debugAppStatusInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
