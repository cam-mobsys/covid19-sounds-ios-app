//
//  AgeView.swift
//  covid19-sounds
//
//
//  Authors (by order of contribution):
//
//    Andreas Grammenos
//    Api Hastanasombat
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI

/// This `View` that deals with the age group gathering from the user.
///
struct AgeView: View {
  /// Scope in the environment objects.
  @EnvironmentObject var initialQuestionnaireInstance: InitialQuestionnaireInstance
  /// Age state variable.
  @State private var age_choice = 0
  /// Age choices for the Picker.
  let age_choices: [KeyValueTuple] = [
    ("pnts", "Prefer not to say"),
    ("16-19", "16-19"),
    ("20-29", "20-29"),
    ("30-39", "30-39"),
    ("40-49", "40-49"),
    ("50-59", "50-59"),
    ("60-69", "60-69"),
    ("70-79", "70-79"),
    ("80-89", "80-89"),
    ("90-", "90 and above")
  ]
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      //
      Spacer()
      //
      Text("How old are you?")
        .font(.system(size: 23, weight: .semibold, design: .rounded))
      //
      // we have to have an outside variable to select the picked values
      Picker(selection: $age_choice, label: Text("age")) {
        ForEach(0 ..< age_choices.count) {
          Text(self.age_choices[$0].value)
        }
      }
      .padding(.top, -40.0)
      .labelsHidden()
      //
      Spacer().frame(height: 40)
      //
      NavigationLinkFactory<ExistingConditionsView>(nextView: ExistingConditionsView())
        .modifier(NavigationLinkModifier({
          log.info("Age selected was: \(self.age_choices[self.age_choice].key)")
          // updating the envrironment object for the initial survey
          self.initialQuestionnaireInstance.age = self.age_choices[self.age_choice].key
        }))
      //
      Spacer()
      //
    }.modifier(AppBackgroundStyle())
  }
}

// only render this in debug mode
#if DEBUG
struct AgeView_Previews: PreviewProvider {
  static var previews: some View {
    AgeView()
      .environmentObject(debugInitialQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
