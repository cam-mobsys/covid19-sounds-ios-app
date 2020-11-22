//
//  HospitalView.swift
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

/// This `View` is responsible for showing the Hospitalisation choices for the user.
///
struct HospitalView: View {
  // the `DailyQuestionnaireInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  // the state variable that tracks the user choice
  @State private var hospitalChoice = 0
  // the available hospital status choices
  private let hospitalChoices: [KeyValueTuple] = [
    ("no", "No"),
    ("yes", "Yes"),
    ("ptns", "Prefer not to say")
  ]
  //
  /// The `View` body definition
  var body: some View {
    //
    VStack {
      //
      Spacer()
      //
      TextViewFactory("Are you in hospital now?")
      //
      // The way to get the actual values from the picker
      Picker(selection: $hospitalChoice, label: Text("Hospital")) {
        ForEach(0 ..< hospitalChoices.count) {
          Text(self.hospitalChoices[$0].value)
        }
      }.padding(.top, -35.0).labelsHidden()
      //
      NavigationLinkFactory<AudioBreatheViewExt>(nextView: AudioBreatheViewExt())
        .modifier(NavigationLinkModifier({
          // wrap in a variable
          let hospitalChoiceValue = self.hospitalChoices[self.hospitalChoice].key
          // log it
          log.info("Hospital prompt replied with: \(hospitalChoiceValue).")
          // conveniently put it in the daily survey
          self.dailyQuestionnaireInstance.hospitalStatus = hospitalChoiceValue
        }))
      //
      Spacer()
      //
    }.modifier(AppBackgroundStyle())
  }
}

// only include this in debug view
#if DEBUG
struct HospitalView_Previews: PreviewProvider {
  static var previews: some View {
    HospitalView()
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
