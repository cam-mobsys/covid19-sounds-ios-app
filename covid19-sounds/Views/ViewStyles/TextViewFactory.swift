//
//  TextViewFactory.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI

/// This `View` is responsible for generating a customised text view based on initialisation parameters; every
/// parameter apart from the actual text has a default and is not needed unless it requires changing.
///
struct TextViewFactory: View {
  // the size of the text
  private let size: CGFloat
  // the localised text to be used as a key to find the localised representation
  private let text: LocalizedStringKey
  // the padding set
  private let padding: Edge.Set
  // the font to be used
  private let font: Font
  //
  /// This is the default constructor for the `TextViewFactory`.
  ///
  /// - Parameter text: a `LocalizedStringKey` text that can be used with translated strings
  ///
  /// - Parameter size: the `CGFloat` instance that sets the size, default value is 23
  ///
  /// - Parameter padding: the `Edge.Set` instance and the default is `.horizontal` (only)
  ///
  /// - Parameter font: the type of `Font` used, the default is `nil` and we use the `.system` font.
  ///
  init(_ text: LocalizedStringKey,
       size: CGFloat = 23,
       padding: Edge.Set = .horizontal,
       font: Font? = nil) {
    self.text = text
    self.size = size
    self.padding = padding
    // check if we have a font argument
    if font == nil {
      self.font = .system(size: self.size, weight: .semibold, design: .rounded)
    } else {
      self.font = font!
    }
  }
  //
  /// The `View` body
  var body: some View {
    VStack {
      Text(text)
        .font(self.font)
        .padding(self.padding)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
    }
  }
}

// only render this in debug mode.
#if DEBUG
struct TextViewFactory_Previews: PreviewProvider {
  static var previews: some View {
    TextViewFactory("some text")
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
