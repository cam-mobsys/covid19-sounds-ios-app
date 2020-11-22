//
//  IntroductionTextView.swift
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

/// The view that is responsible to display the introduction text in our app tucked in a tidy view.
///
struct IntroductionLandingTextView: View {
  /// the `View` body definition.
  var body: some View {
    //
    NavigationView {
      //
      VStack {
        //
        Text("COVID19 Sounds")
          .font(.system(size: 30, weight: .semibold, design: .rounded))
          .padding(.bottom, 25.0)
        //
        Spacer()//.frame(maxHeight: 40)
        //
        TextViewFactory("topTextIntroductionView",
                        padding: [.leading, .bottom, .trailing],
                        font: .headline)
        //
        TextViewFactory("bottomTextIntroductionView",
                        padding: .all,
                        font: .headline)
        //
        Spacer()
        //
        NavigationLinkFactory<AgeCheckView>(nextView: AgeCheckView())
          .modifier(NavigationLinkModifier({
            log.info("Tapped next")
          }))
        // spacer
        Spacer().frame(maxHeight: 60)
        //
        Image("cam-logo")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.horizontal, 100.0)
          .padding(.bottom, 20.0)
        //
      }
      .modifier(AppBackgroundStyle())
    }
  }
}

// only render this in debug mode
#if DEBUG
struct IntroductionLandingTextView_Previews: PreviewProvider {
  static var previews: some View {
    IntroductionLandingTextView()
  }
}
#endif
