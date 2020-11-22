//
//  ActivityIndicator.swift
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

/// The helper struct which creates and presents an  Activity indicator describing the stage the uploading process is
/// this was inspired from: https://stackoverflow.com/questions/56496638/activity-indicator-in-swiftui
///
struct ActivityIndicator: UIViewRepresentable {
  /// the variable indicating if it's animating or not
  @Binding var isAnimating: Bool
  /// the style of the animation
  let style: UIActivityIndicatorView.Style
  /// The function that creates a `UIView` of type `UIActivityIndicatorView` that is shown.
  ///
  /// - Parameter context: the context of type `UIViewRepresentableContext` to apply the `UIActivityIndicatorView`.
  ///
  /// - Returns: the initialised `UIActivityIndicatorView` instance.
  ///
  func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
    return UIActivityIndicatorView(style: style)
  }
  /// The function that updates the `UIActivityIndicatorView` in the provided context
  /// of type `UIViewRepresentableContext`.
  ///
  /// - Parameter uiView: the `UIActivityIndicatorView` instance.
  ///
  /// - Parameter context: the context instance of type `UIViewRepresentableContext` which the indicator lives.
  ///
  func updateUIView(_ uiView: UIActivityIndicatorView,
                    context: UIViewRepresentableContext<ActivityIndicator>) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
  }
}
