//
//  COVIDStatusPossibleInfection.swift
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

/// This `View` is respoinsble to querying the user of a _self-reported_ possible COVID19 infection.
///
struct COVIDStatusPossibleInfectionView: View {
  /// the environment object for the daily survey
  @EnvironmentObject var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  /// status variable for the selection
  @State private var cov19_status_possible_infection_choice = 0
  /// contains the picker choices for the covid19 status
  private let cov19_status_possible_infection_choices: [KeyValueTuple] = [
    ("neverThinkHadCOVIDNever", "Never"),
    ("neverThinkHadCOVIDNow", "Yes, now"),
    ("neverThinkHadCOVIDLast14", "Yes, in last 14 days"),
    ("neverThinkHadCOVIDOver14", "Yes, over 14 days ago")
  ]
  //
  /// the `View` body definition.
  var body: some View {
    //
    VStack {
      //
      Spacer()
      //
      Text("Do you think you ever have/had a COVID-19 infection?")
        .font(.system(size: 23, weight: .semibold, design: .rounded))
        .padding(.horizontal, 20.0)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
      //
      // That's the only way to get the picker value and label
      //
      Picker(selection: $cov19_status_possible_infection_choice, label: Text("possible_infection")) {
        ForEach(0 ..< cov19_status_possible_infection_choices.count) {
          Text(self.cov19_status_possible_infection_choices[$0].value)
        }
      }.padding(.top, -35.0).labelsHidden()
      //
      Spacer().frame(height: 40)
      //
      NavigationLinkFactory<HospitalView>(nextView: HospitalView())
        .modifier(NavigationLinkModifier({
          // conveniently put it in this variable
          let choice = self.cov19_status_possible_infection_choice
          let cov19_choice_value = self.cov19_status_possible_infection_choices[choice].key
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
struct TestCOVIDStatusPossibleInfectionView_Previews: PreviewProvider {
  static var previews: some View {
    COVIDStatusPossibleInfectionView()
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
