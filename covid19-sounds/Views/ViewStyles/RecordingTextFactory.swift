//
//  AudioViewTextFactory.swift
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

/// This is a specific `View` used as a text factory within  `AudioRecordViewBase` and shows the actual
/// recording text according to the type of sound we wish to record.
///
struct RecordingTextFactory: View {
  /// the audio type to record
  private let audioType: AudioRecordingType
  //
  /// The default constructor for the `RecordingTextFactory` which takes as input the
  /// `AudioRecordingType`.
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
        TextViewFactory("breatheRecordingText")
      case .read:
        TextViewFactory("readRecordingTopText")
        //
        TextViewFactory("readRecordingContentText")
        //
        TextViewFactory("pressStopText")
      case .cough:
        TextViewFactory("coughRecordingText")
      }
      // it should not be anything else!
    }
  }
}

// this should only be shown in debug
#if DEBUG
struct RecordingTextFactory_Previews: PreviewProvider {
  static var previews: some View {
    RecordingTextFactory(AudioRecordingType.read)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
