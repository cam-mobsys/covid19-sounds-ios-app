//
//  Symptoms.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI

/// The `View` that contains the symptoms list, currently we have the following symptoms supported
///
struct SymptomsView: View {
  /// the `DailyQuestionnaireInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  /// the state variable that is used to hide the navigation link.
  @State private var navigate = false
  /// the state variable that shows an alert, if needed.
  @State private var alert = false
  /// the state variable for the symptoms state.
  @State private var symptomsState = [Bool](repeating: false, count: 14)
  /// the index for none.
  private var noneIndex = 0
  /// the index for prefer not to say.
  private var pntsIndex = 1
  /// the available symptom choices.
  private var symptoms: [KeyValueTuple] = [
    ("None", "None"),
    ("pnts", "Prefer not to say"),
    ("fever", "Fever"),
    ("chills", "Chills"),
    ("drycough", "Dry cough"),
    ("wetcough", "Wet cough"),
    ("shortbreath", "Difficulty breathing or feeling short of breath"),
    ("tightness", "Tightness in your chest"),
    ("headache", "Headache"),
    ("muscleache", "Muscle aches"),
    ("sorethroat", "Sore throat"),
    ("runnyblockednose", "Runny or blocked nose"),
    ("smelltasteloss", "Loss of taste and smell"),
    ("dizziness", "Dizziness, confusion or vertigo")
  ]
  //
  /// The `View` body
  var body: some View {
    //
    NavigationView {
      //
      VStack {
        //
        Text("symptomsText")
          .font(.headline)
          .multilineTextAlignment(.center)
          .padding([.leading, .trailing], 15.0)
          .padding(.top, -70)
          .padding(.bottom, -30)
        //
        Form {
          Section {
            //
            // Disable none if pnts or any other symptom is selected
            //
            Toggle(isOn: self.$symptomsState[noneIndex]) {
              Text(symptoms[noneIndex].value)
            }.disabled(self.symptomsState[2..<symptoms.count].contains(true) || self.symptomsState[pntsIndex] == true)
            //
            //
            // Disable pnts if none or any other symptom is selected
            //
            Toggle(isOn: self.$symptomsState[pntsIndex]) {
              Text(symptoms[pntsIndex].value)
            }.disabled(self.symptomsState[2..<symptoms.count].contains(true) || self.symptomsState[noneIndex] == true)
            //
            //
            // List all symptoms except last 2 (pnts and none)
            // Disable if none or pnts is selected
            //
            ForEach(2..<symptoms.count) { index in
              Toggle(isOn: self.$symptomsState[index]) {
                Text(self.symptoms[index].value)
              }.disabled(self.symptomsState[self.noneIndex] == true || self.symptomsState[self.pntsIndex] == true)
            }
            //
          }
        }
        //
        NavigationLink(destination: COVIDStatusView(), isActive: self.$navigate) {
          Text("")
        }
        //
        Button {
          if (!self.symptomsState.contains {$0 == true}) {
            log.info("No symptoms selected and next button tapped")
            self.alert = true
          } else {
            // Get conditions where toggle value is true
            let presentSymptoms = self.symptoms.indices.filter {
              self.symptomsState[$0] == true
            }.map({ self.symptoms[$0].key })
            let presentSymptomsString = presentSymptoms.joined(separator: ",")
            log.info("Present Symptoms Selected: \(presentSymptomsString)")
            // updating the environment object for the initial survey
            self.dailyQuestionnaireInstance.symptoms = presentSymptomsString
            self.navigate = true
          }
        } label: {
          Text("Next")
            .font(.custom("Next", size: 23))
        }.buttonStyle(GradientBackgroundStyle())
      }
      .alert(isPresented: self.$alert) {
        Alert(title: Text("Invalid Selection"),
              message: Text("Please select one or more options."),
              dismissButton: .default(Text("OK")))
      }
      //
    }
    //
  }
  //
}

// only render this in debug mode
#if DEBUG
struct SymptomsView_Previews: PreviewProvider {
  static var previews: some View {
    SymptomsView()
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
