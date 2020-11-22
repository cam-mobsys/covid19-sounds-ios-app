//
//  AudioReadViewExt.swift
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

/// The view that is responsible for recording the reading sounds.
///
struct AudioReadViewExt: View {
  // sets the recording type for the `AudioViewCore`
  private let recordingType: AudioRecordingType = .read
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
struct AudioReadViewExt_Previews: PreviewProvider {
  static var previews: some View {
    AudioReadViewExt()
  }
}
#endif
