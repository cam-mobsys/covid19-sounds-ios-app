//
//  Styles.swift
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

/// The nifty little gradient background style used throughout our buttons and the style, since long,
/// is packed into a convinient helper `ButtonStyle` which we can easily apply.
///
struct GradientBackgroundStyle: ButtonStyle {
  /// the minimum width of the button
  private let minWidth: CGFloat
  //
  /// The default constructor which takes as an (optional) argument the minimum width of the button.
  /// In our case we use 200 for the normal and 100 for the small.
  ///
  /// - Parameter minWidth: the `CGFloat` value to be used for the button `minWidth`.
  ///
  init(minWidth: CGFloat = 200) {
    self.minWidth = minWidth
  }
  /// This function styles the button to have a round appearnce and a blue to purple gradient with the
  /// difference being the minimum width
  ///
  /// - Parameter configuration: the configuration used for the button and to alter.
  ///
  /// - Returns: a `View`
  ///
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .frame(minWidth: minWidth)
      .foregroundColor(Color.white)
      .padding()
      .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                 startPoint: .leading, endPoint: .trailing))
      .cornerRadius(15.0)
      .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
  }
}

/// The background style that is used throughout our application and is packed as a `ViewModifier`
/// which can be easily reused.
///
struct AppBackgroundStyle: ViewModifier {
  /// This is the main transformer function that takes a `Content` instance and applies the modifications; upon
  /// completion a new `View` is returned with the modified properties.
  ///
  /// - Parameter content: the `Content` instance to be transformed.
  ///
  /// - Returns: a `View`.
  ///
  func body(content: Content) -> some View {
    content
      .frame(minWidth: 0,
             maxWidth: .infinity,
             minHeight: 0,
             maxHeight: .infinity,
             alignment: .center)
      .background(
        Image("bg")
          .resizable()
          .opacity(0.5)
          .edgesIgnoringSafeArea(.all)
    )
  }
}
