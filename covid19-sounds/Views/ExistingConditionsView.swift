//
//  ExistingConditions.swift
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

/// This `View` is responsible for gathering the existing conditions of the user.
///
struct ExistingConditionsView: View {
  // the `InitialQuestionnaireInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var initialQuestionnaireInstance: InitialQuestionnaireInstance
  //
  @State private var navigate = false
  //
  @State private var alert = false
  //
  @State private var conditionsState = [Bool](repeating: false, count: 18)
  // the condition choices
  private let conditions: [KeyValueTuple] = [
    ("None", "noneTag"),
    ("pnts", "Prefer not to say"),
    ("asthma", "Asthma"),
    ("cystic", "Cystic fibrosis"),
    ("copd", "COPD/Emphysema"),
    ("pulmonary", "Pulmonary fibrosis"),
    ("lung", "Other lung disease"),
    ("hbp", "High Blood Pressure"),
    ("angina", "Angina"),
    ("stroke", "Previous stroke or Transient Ischaemic Attack"),
    ("heart", "Previous heart attack"),
    ("valvular", "Valvular heart disease"),
    ("otherHeart", "Other heart disease"),
    ("diabetes", "Diabetes"),
    ("cancer", "Cancer"),
    ("organ", "Previous organ transplant"),
    ("hiv", "HIV or an impaired immune system"),
    ("long", "Other long-term condition")
  ]
  // the none value index.
  private var noneIndex = 0
  // the prefer not to say value index.
  private var pntsIndex = 1
  // the possible values for the respi. conditions
  private var respiratoryConditionIndices = 2..<7
  // the possible values for the cardio. conditions
  private var cardiovascularConditionIndices = 7..<13
  // the possible values for the rest of the conditions
  private var otherConditionIndices = 13..<18

  /// the `View` body definition.
  var body: some View {
    VStack {
      Text("medConditionsText")
        .font(.system(size: 17, weight: .semibold, design: .rounded))
        .padding(.bottom, 20)
      Form {
        //
        // If any condition is selected or pnts is selected, disable
        //
        Toggle(isOn: self.$conditionsState[noneIndex]) {
          Text("noneTag")
        }
        .disabled(self.conditionsState[2..<self.conditionsState.count].contains(true) ||
          self.conditionsState[pntsIndex] == true)
        //
        // If any condition is selected or none is selected, disable
        //
        Toggle(isOn: self.$conditionsState[pntsIndex]) {
          Text("Prefer not to say")
        }
        .disabled(self.conditionsState[2..<self.conditionsState.count].contains(true) ||
                    self.conditionsState[noneIndex] == true)
        //
        // Respiratory related conditions
        //
        Section(header:
          Text("Respiratory")
            .font(.subheadline)
            .fontWeight(.bold)) {
                ForEach(respiratoryConditionIndices) { index in
                  // If none or pnts is selected, disable
                  Toggle(isOn: self.$conditionsState[index]) {
                    Text(self.conditions[index].value)
                  }.disabled(self.conditionsState[self.pntsIndex] == true ||
                              self.conditionsState[self.noneIndex] == true)
                }
        }
        // Cardiovascular related
        Section(header:
          Text("Cardiovascular")
            .font(.subheadline)
            .fontWeight(.bold)) {
              ForEach(cardiovascularConditionIndices) { index in
                // If none or pnts is selected, disable
                Toggle(isOn: self.$conditionsState[index]) {
                  Text(self.conditions[index].value)
                }.disabled(self.conditionsState[self.pntsIndex] == true ||
                            self.conditionsState[self.noneIndex] == true)
              }
        }
        // Other
        Section(header:
          Text("Other")
            .font(.subheadline)
            .fontWeight(.bold)) {
              ForEach(otherConditionIndices) { index in
                // If none or pnts is selected, disable
                Toggle(isOn: self.$conditionsState[index]) {
                  Text(self.conditions[index].value)
                }.disabled(self.conditionsState[self.pntsIndex] == true ||
                            self.conditionsState[self.noneIndex] == true)
              }
        }
        //
      }
      //
      NavigationLink(destination: SmokeStatusView(), isActive: self.$navigate) {
        Text("")
      }
      //
      Button {
        if (!self.conditionsState.contains {$0 == true}) {
          log.info("No values selected and next button tapped")
          self.alert = true
        } else {
          // Get conditions where toggle value is true
          let presentConditions = self.conditions.indices.filter {
              self.conditionsState[$0] == true
          }.map({ self.conditions[$0].key })
          //
          // join them to construct the upload string
          let presentConditionsString = presentConditions.joined(separator: ",")
          log.info("Previous Conditions Selected: \(presentConditionsString)")
          // updating the environment object for the initial survey
          self.initialQuestionnaireInstance.medicalHistory = presentConditionsString
          self.navigate = true
        }
      } label: {
        Text("Next")
          .font(.custom("Next", size: 23))
      }.buttonStyle(GradientBackgroundStyle())
      //
    }.alert(isPresented: self.$alert) {
      Alert(title: Text("Invalid Selection"),
            message: Text("Please select one or more options."),
            dismissButton: .default(Text("OK")))
    }
    //
  }
}

// only render this in debug mode
#if DEBUG
struct ExistingConditionsView_Previews: PreviewProvider {
  static var previews: some View {
    ExistingConditionsView()
      .environmentObject(debugInitialQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
