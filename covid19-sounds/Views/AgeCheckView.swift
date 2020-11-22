//
//  AgeCheckView.swift
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

/// This `View` asks for age consent from the user.
///
struct AgeCheckView: View {
  /// scope in the user instance
  @EnvironmentObject private var userInstance: UserInstance
  //
  /// The main body of the `View`
  var body: some View {
    // start the Vertical stay to lay down the view elments
    VStack {
      // first a spacer
      Spacer()
      // now add a the text
      TextViewFactory("participationText", padding: .all)
      //
      Spacer().frame(height: 80)
      //
      TextViewFactory("confirmOver16", padding: .all)
      //
      // a bit more evently spaced
      Spacer().frame(height: 40)
      //
      // now add the navigation link for the age confirmation
      //GenderView
      NavigationLinkFactory<GenderView>(nextView: GenderView(), text: "over16OK")
        .modifier(NavigationLinkModifier({
          log.info("Consent given - moving on")
        }))
      //
      // another spacer to even things out.
      Spacer()
      //
    }.modifier(AppBackgroundStyle())
  }
}

// only render this in debug mode
#if DEBUG
struct AgeCheckView_Previews: PreviewProvider {
  // render the preview
  static var previews: some View {
    return AgeCheckView()
      .environmentObject(debugUserInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
