//
//  EndDemographicsView.swift
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

/// This `View` is shown once the initial demographic survey is completed.
///
struct EndDemographicsView: View {
  // scope in the environment objects
  @EnvironmentObject var userInstance: UserInstance
  // scope in the environment objects
  @EnvironmentObject var initialQuestionnaireInstance: InitialQuestionnaireInstance
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      Spacer()
      //
      TextViewFactory("endDemographicsText")
      //
      Spacer()
        .frame(height: 60)
      //
      // direct the user to the home view - but after we properly
      // set the can upload anc consent given flag.
      //
      Button {
        // log that the initial demographics are completed.
        log.info("Initial demographics survey completed - raising consent and can upload flags.")
        // set that the initial questionnaire is filled
        self.userInstance.initialQuestionnaireFilled = true
        // also, if we come from this view - can upload is always valid
        self.userInstance.canSubmitDailyQuestionnaire = true
      } label: {
        // put everything in a horizontal stack
        HStack {
          Text("Next")
            .font(.custom("Next", size: 23))
        }
      }
      .buttonStyle(GradientBackgroundStyle())
      //
      Spacer()
      //
    }.modifier(AppBackgroundStyle())
  }
}

// only render this preview in debug mode
#if DEBUG
struct EndDemographicsView_Previews: PreviewProvider {
  static var previews: some View {
    EndDemographicsView()
      .environmentObject(debugUserInstance)
      .environmentObject(debugInitialQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
