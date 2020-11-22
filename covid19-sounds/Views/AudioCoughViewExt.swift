//
//  AudioCoughViewExt.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI
import Combine

/// The `View` that is responsible for recording the cough sounds.
///
struct AudioCoughViewExt: View {
  /// sets the recording type for the `AudioViewCore`
  private let recordingType: AudioRecordingType = .cough
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      // spawn the audio view core for the breathing recording
      AudioRecorderViewBase(recordingType: .constant(self.recordingType))
    }
  }
}

// only render this in debug mode
#if DEBUG
struct AudioCoughViewExt_Previews: PreviewProvider {
  static var previews: some View {
    AudioCoughViewExt()
  }
}
#endif
