//
//  EndviewBottomTextView.swift
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

/// This `View` is responsible for displaying the lower portion of the `EndView`.
///
struct EndViewBottomTextView: View {
  /// the `View` body definition.
  var body: some View {
    VStack {
      //
      Spacer()
      //
      Text("You can view our privacy policy at:")
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .multilineTextAlignment(.center)
      //
      Text("https://covid-19-sounds.org/en/privacy")
        .font(.system(size: 18, weight: .regular, design: .rounded))
        .foregroundColor(Color.blue)
        .multilineTextAlignment(.center)
        .onTapGesture {
          UIApplication.shared.open(URL(string: "https://covid-19-sounds.org/en/privacy")!)
      }
      //
      Spacer()
      //
      Text("UID: \(userInstance.username)")
        .font(.footnote)
      //
      Text("App version \(AppDetails.appVersion ?? "Error Fetching Version") Build: \(AppDetails.appBuild ?? "")")
        .font(.footnote)
      //
      Spacer().frame(height: 20)
      //
      Image("cam-logo")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.horizontal, 100.0)
        .padding(.bottom, 20.0)
      //
      Spacer().frame(height: 20)
      //
    }
    .frame(minWidth: 0,
           maxWidth: .infinity,
           minHeight: 0,
           maxHeight: .infinity,
           alignment: .center)
  }
}

// only render this in debug mode
#if DEBUG
struct EndViewBottomTextView_Previews: PreviewProvider {
  static var previews: some View {
    EndViewBottomTextView()
  }
}
#endif
