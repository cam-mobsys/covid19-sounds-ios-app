//
//  PreRecordingTextFactory.swift
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

/// This is a specific `View` used as a text factory employed in `AudioRecordViewBase` and shows
/// the _pre-recording_ text according to the type of sound we wish to record.
///
struct PreRecordingTextFactory: View {
  /// the audio recording type of type `AudioRecordingType`
  private let audioType: AudioRecordingType
  /// The default constructor which takes as an argument the `AudioRecordingType` and outputs the
  /// text using the `TextViewFactory` accordingly. Note that the text is localised.
  ///
  init(_ audioType: AudioRecordingType) {
    self.audioType = audioType
  }
  //
  /// The `View` body
  var body: some View {
    VStack {
      switch audioType {
      case .breathe:
        TextViewFactory("breathePreRecordingText")
      case .read:
        //
        TextViewFactory("readPreRecordingText")
        //
        TextViewFactory("readRecordingContentText")
        //
      case .cough:
        TextViewFactory("coughPreRecordingText")
      }
      // it should not be anything else!
    }
  }
}

// only render this in debug mode.
#if DEBUG
struct PreRecordingTextFactory_Previews: PreviewProvider {
  static var previews: some View {
    PreRecordingTextFactory(AudioRecordingType.read)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
