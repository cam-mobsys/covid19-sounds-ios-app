//
//  GenderView.swift
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

/// This `View` is responsible for showing the Gender selection choices for the user.
///
struct GenderView: View {
  // the `InitialQuestionnaireInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var initialQuestionnaireInstance: InitialQuestionnaireInstance
  // The sex state variable
  @State private var sex_choice = 0
  // the sex choices
  private let sex_choices: [KeyValueTuple] = [
    ("Male", "maleTag"),
    ("Female", "femaleTag"),
    ("Other", "otherTag"),
    ("ptns", "Prefer not to say")
  ]

  /// the body view definition
  var body: some View {
    VStack {
      //
      Spacer()
      //
      TextViewFactory("bioSex")
      //
      // that's the only way to get the label values
      Picker(selection: $sex_choice, label: Text("sex")) {
        ForEach(0 ..< sex_choices.count) {
          Text(self.sex_choices[$0].value)
        }
      }
      .padding(.top, -35.0)
      .labelsHidden()
      //
      NavigationLinkFactory<AgeView>(nextView: AgeView())
        .modifier(NavigationLinkModifier({
          // conveniently wrap it
          let selected_sex = self.sex_choices[self.sex_choice].key
          // log it
          log.info("Gender selected: \(selected_sex)")
          // assign it to our instance structure
          self.initialQuestionnaireInstance.sex = selected_sex
        }))
      //
      Spacer()
    }.modifier(AppBackgroundStyle())
  }
}

// only render this in debug mode
#if DEBUG
struct GenderView_Previews: PreviewProvider {
  static var previews: some View {
    GenderView()
      .environmentObject(debugInitialQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
