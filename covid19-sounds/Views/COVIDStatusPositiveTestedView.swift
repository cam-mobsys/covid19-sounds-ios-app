//
//  COVIDStatusPositiveTested.swift
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

/// This `View` is responsible for checking the _self-reported_ positive COVID19 status
/// from the users.
///
struct COVIDStatusPositiveTestedView: View {
  /// the environment object for the daily survey
  @EnvironmentObject private var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  /// status variable for the selection
  @State private var cov19_status_tested_positive_choice = 0
  /// contains the picker choices for the covid19 status
  private let cov19_status_tested_positive_choices: [KeyValueTuple] = [
    ("positiveLast14", "Last 14 days"),
    ("positiveOver14", "Over 14 days ago")
  ]
  //
  /// the `View` body definition.
  var body: some View {
    //
    VStack {
      //
      Spacer()
      //
      Text("When did you tested positive?")
        .font(.system(size: 23, weight: .semibold, design: .rounded))
        .padding(.horizontal, 20.0)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
      //
      // That's the only way to get the picker value and label
      //
      Picker(selection: $cov19_status_tested_positive_choice, label: Text("tested_positive")) {
        ForEach(0 ..< cov19_status_tested_positive_choices.count) {
          Text(self.cov19_status_tested_positive_choices[$0].value)
        }
      }.padding(.top, -35.0).labelsHidden()
      //
      Spacer().frame(height: 40)
      //
      NavigationLinkFactory<HospitalView>(nextView: HospitalView())
        .modifier(NavigationLinkModifier({
          // conveniently put it in this variable
          let choice = self.cov19_status_tested_positive_choice
          let cov19_choice_value = self.cov19_status_tested_positive_choices[choice].key
          // log it.
          log.info("COVID-19 status, tested positive reported: \(cov19_choice_value).")
          // store the COVID-19 reported status to the daily survey instance
          self.dailyQuestionnaireInstance.covidStatus = cov19_choice_value
        }))
      //
      Spacer()
      //
    }.modifier(AppBackgroundStyle())
  }
}

// only do live preview on debug mode.
#if DEBUG
struct TestCOVIDStatusPositiveTestedView_Previews: PreviewProvider {
  static var previews: some View {
    COVIDStatusPositiveTestedView()
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
