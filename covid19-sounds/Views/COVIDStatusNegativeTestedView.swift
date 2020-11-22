//
//  COVIDStatusNegativeTested.swift
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

/// This `View` queries the user of his _self-reported_ negative COVID19 status.
///
struct COVIDStatusNegativeTestedView: View {
  /// the environment object for the daily survey
  @EnvironmentObject private var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  /// state variable for the selection
  @State private var cov19_status_negative_choice = 0
  /// contains the picker choices for the covid19 status
  private let cov19_status_negative_tested_choices: [KeyValueTuple] = [
    ("negativeNever", "Never"),
    ("negativeLast14", "Last 14 days"),
    ("negativeOver14", "Over 14 days ago")
  ]
  //
  /// the `View` body definition.
  var body: some View {
    //
    VStack {
      //
      Spacer()
      //
      Text("Have you tested positive before?")
        .font(.system(size: 23, weight: .semibold, design: .rounded))
        .padding(.horizontal, 20.0)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
      //
      // That's the only way to get the picker value and label
      //
      Picker(selection: $cov19_status_negative_choice, label: Text("negative_tested")) {
        ForEach(0 ..< cov19_status_negative_tested_choices.count) {
          Text(self.cov19_status_negative_tested_choices[$0].value)
        }
      }.padding(.top, -35.0).labelsHidden()
      //
      Spacer().frame(height: 40)
      //
      NavigationLinkFactory<HospitalView>(nextView: HospitalView())
        .modifier(NavigationLinkModifier({
          // conveniently put it in this variable
          let cov19_choice_value = self.cov19_status_negative_tested_choices[self.cov19_status_negative_choice].key
          // log it.
          log.info("COVID-19 status, tested negative reported: \(cov19_choice_value).")
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
struct TestCOVIDStatusNegativeTestedView_Previews: PreviewProvider {
  static var previews: some View {
    COVIDStatusNegativeTestedView()
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
