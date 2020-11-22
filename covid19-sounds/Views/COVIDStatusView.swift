//
//  TestView.swift
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
import Foundation

/// This `View` handles the _self-reported_ COVID19 status of the user - it has four possible outcomes
///  based on the replies provided.
///
struct COVIDStatusView: View {
  /// the environment object for the daily survey
  @EnvironmentObject var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  /// status variable for the selection
  @State private var cov19_status_choice = 0
  /// contains the picker choices for the covid19 status
  private let cov19_status_choices: [KeyValueTuple] = [
    ("statusNeverTested", "Never tested"),  // goes to possible infection
    ("statusPositive", "Positive"),         // goes to positive test
    ("statusNegative", "Negative"),         // goes to negative test
    ("ptns", "Prefer not to say")           // goes to hospital view
  ]
  //
  /// the `View` body definition.
  var body: some View {
    //
    VStack {
      //
      Spacer()
      //
      TextViewFactory("covidStatusLegend")
      //
      // That's the only way to get the picker value and label
      //
      Picker(selection: $cov19_status_choice, label: Text("positive")) {
        ForEach(0 ..< cov19_status_choices.count) {
          Text(self.cov19_status_choices[$0].value)
        }
      }.padding(.top, -35.0).labelsHidden()
      //
      Spacer().frame(height: 40)
      //
      NavigationLinkFactory<AnyView>(nextView: covidStatusViewFactory(self.cov19_status_choice,
                                                                      choices: self.cov19_status_choices))
        .modifier(NavigationLinkModifier())
      //
      Spacer()
      //
    }.modifier(AppBackgroundStyle())
  }
}

/// Helper function that maps choice to destination view.
///
/// - Parameter `choice`: the index of the choice, if `-1` then it's initial.
///
/// - Parameter `choices`: the `[KeyValueTuple]` that provides the choices
///
/// - Returns `View`:  the view instance to go based on `choice`.
///
private func covidStatusViewFactory(_ choice: Int, choices: [KeyValueTuple]) -> AnyView {
  // check which choice we have so far.
  if choice == -1 {
    log.info("Arrival - return the default (HospitalView)")
    return AnyView(HospitalView())
  }
  //
  // fetch the choice
  let val = choices[choice]
  // check what we are doing
  if val.key == "statusNeverTested" {
    log.info("Will go to COVIDStatusPossibleInfectionView")
    return AnyView(COVIDStatusPossibleInfectionView())
  } else if val.key == "statusPositive" {
    log.info("Will go to COVIDStatusPositiveTestedView")
    return AnyView(COVIDStatusPositiveTestedView())
  } else if val.key == "statusNegative" {
    log.info("Will go to COVIDStatusNegativeTestedView")
    return AnyView(COVIDStatusNegativeTestedView())
  } else { // pnts or act as a faillback choice...
    log.info("Will go to HospitalView directly - logging pnts as reply.")
    // store the COVID-19 reported status to the daily survey instance
    dailyQuestionnaireInstance.covidStatus = "\(val.value)"
    return AnyView(HospitalView())
  }
}

// only do live preview on debug mode.
#if DEBUG
struct TestCOVIDStatusView_Previews: PreviewProvider {
  static var previews: some View {
    COVIDStatusView()
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
