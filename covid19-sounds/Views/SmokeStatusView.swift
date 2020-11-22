//
//  Smoking.swift
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

/// This `View` is responsible for gathering the smoke status of the user based on the available
/// choices.
///
struct SmokeStatusView: View {
  /// the `InitialQuestionnaireInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var initialQuestionnaireInstance: InitialQuestionnaireInstance
  /// the variable that holds the smoke status choice from the user.
  @State private var smokeStatusChoice = 0
  /// the smoke status available choices.
  private let smokeStatusChoices: [KeyValueTuple] = [
    ("never", "Never smoked"),
    ("ltOnce", "Less than once a day"),
    ("1to10", "1-10 cigarettes per day"),
    ("11to20", "11-20 cigarettes per day"),
    ("21+", "21+ cigarettes per day"),
    ("ecig", "e-cigarettes only"),
    ("ex", "Ex-smoker"),
    ("ptns", "Prefer not to say")
  ]
  //
  /// the `View` body definition
  var body: some View {
    //
    VStack {
      //
      Spacer()
      //
      TextViewFactory("smokeStatusText")
      //
      Picker(selection: $smokeStatusChoice, label: Text("smoker")) {
        ForEach(0 ..< smokeStatusChoices.count) {
          Text(self.smokeStatusChoices[$0].value)
        }
      }
      .padding(.top, -35.0)
      .labelsHidden()
      //
      Spacer().frame(height: 40)
      //
      NavigationLinkFactory<EndDemographicsView>(nextView: EndDemographicsView())
        .modifier(NavigationLinkModifier({
          // conveniently wrap it
          let smokingHistoryValue = self.smokeStatusChoices[self.smokeStatusChoice].key
          // log it
          log.info("Smoking status selected was: \(smokingHistoryValue)")
          // updating the envrironment object for the initial survey
          self.initialQuestionnaireInstance.smokingHistory = smokingHistoryValue
        }))
      //
      Spacer()
      //
    }
    .modifier(AppBackgroundStyle())
    //
  }
  //
}

// only render this in debug mode
#if DEBUG
struct SmokingView_Previews: PreviewProvider {
  static var previews: some View {
    SmokeStatusView()
      .environmentObject(debugInitialQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
