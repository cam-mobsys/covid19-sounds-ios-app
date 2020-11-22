//
//  Smoking.swift
//  covid19-sounds
//
//
//  Authors (α-β order):
//
//    Andreas Grammenos
//    Api Hastanasombat
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI

struct SmokeStatusView: View {
  // scope in the environment objects
  @EnvironmentObject var initialSurveyInstance: InitialInfoSurveyInstance
  //
  let smoking_choices = [
    "Never smoked",
    "Ex-smoker",
    "1-10 cigarettes per day",
    "Prefer not to say"
  ]
  //
  @State private var smoking_choice = -1
  //
  var body: some View {
    //
    VStack {
      //
      Spacer()
      //
      Text("Do you, or have you ever smoked (including e-cigarettes)?")
        .font(.title)
        .padding(.horizontal, 20.0)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
      //
      Picker(selection: $smoking_choice, label: Text("smoker")) {
        Text("Never smoked").tag(0)
        Text("Ex-smoker").tag(1)
        Text("1-10 cigarettes per day").tag(2)
        Text("11 or more cigarettes per day").tag(3)
        Text("Prefer not to say").tag(4)
      }.padding(.top, -35.0).labelsHidden()
      //
      Spacer().frame(height: 40)
      //
      NavigationLink(destination: EndDemographicsView()) {
        Text("Next")
          .font(.custom("Next", size: 23))
      }
      .buttonStyle(GradientBackgroundStyle())
      .simultaneousGesture(TapGesture().onEnded({
        log.info("Smoking status selected was: ")
        // updating the envrironment object for the initial survey
        self.initialSurveyInstance.smoking_history = ""
      }))
      //
      Spacer()
      //
    }
    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    .background(
      Image("bg")
        .resizable()
        .opacity(0.5)
        .edgesIgnoringSafeArea(.all)
    )
  }
}

// only render this in debug mode
#if DEBUG
struct SmokingView_Previews: PreviewProvider {
  static var previews: some View {
    SmokeStatusView()
      .environmentObject(debugInitialSurveyInstance)
      .environment(\.locale, .init(identifier: "en"))
  }
}
#endif
