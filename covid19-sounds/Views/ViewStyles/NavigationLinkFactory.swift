//
//  NavigationLinkFactory.swift
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

/// This `View` is designed as a generic view that can take an arbitrary typed `View` and use it as
/// the `destination` in the context of a `NavigationLink`.
///
struct NavigationLinkFactory<TargetView: View>: View {
  /// the next view to be targeted
  let nextView: TargetView
  /// the localised text to be displayed
  let text: LocalizedStringKey
  //
  /// The default constructor for `NavigationLinkFactory`
  ///
  /// - Parameter nextView: the next `View` of type `TargetView` to be targeted next.
  ///
  /// - Parameter text: the `LocalizedStringKey` to be displayed on the text.
  ///
  init(nextView: TargetView, text: LocalizedStringKey = "Next") {
    self.text = text
    self.nextView = nextView
  }
  //
  /// The `View` body
  var body: some View {
    VStack {
      NavigationLink(destination: nextView) {
        HStack {
          Text(text)
            .font(.custom("Next", size: 23))
        }
      }
    }
  }
}
