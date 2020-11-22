//
//  RecorderButtonFactory.swift
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

/// This class generates the styled buttons used for the recording within `AudioRecordingBaseView`; they
/// include the square, circle, and play buttons. Each can be generated based on the `fillName` parameter as well
/// as specifying the `foregroundColor`.
///
/// Additionally, an action handler is provided to execute custom actions.
///
struct RecorderButtonViewFactory: View {
  /// the foreground color for the button.
  private let foregroundColor: Color?
  /// the fill name for the asset used for the button.
  private let fillName: String
  /// the action handler.
  private let action: () -> Void
  //
  /// This is the constructor for the `RecorderButtonViewFactory` which takes a `action` handler and the `fillName`.
  ///
  /// - Parameter action: the handler
  ///
  /// - Parameter fillName: the string that will be used to load the image
  ///
  /// - Parameter foregroundColor: the color for the foreground
  ///
  init(action: @escaping () -> Void, fillName: String, foregroundColor: Color? = nil) {
    self.foregroundColor = foregroundColor
    self.fillName = fillName
    self.action = action
  }
  //
  /// The `View` body
  var body: some View {
    VStack {
      Button(action: self.action) {
        if self.foregroundColor != nil {
          Image(systemName: self.fillName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 70, height: 70)
            .clipped()
            .foregroundColor(self.foregroundColor)
            .padding(.vertical, 30)
        } else {
          Image(systemName: self.fillName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 70, height: 70)
            .clipped()
            .padding(.vertical, 30)
        }
      }
    }
  }
}
