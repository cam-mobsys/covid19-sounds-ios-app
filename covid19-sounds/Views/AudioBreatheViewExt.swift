//
//  AudioBreatheViewExt.swift
//  covid19-sounds
//
//  Created by Andreas Grammenos on 31/10/2020.
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI
import Combine

/// The view that is responsible for recording the breathing sounds.
///
struct AudioBreatheViewExt: View {
  /// sets the recording type for the `AudioViewCore`
  private let recordingType: AudioRecordingType = .breathe
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
struct AudioBreatheViewExt_Previews: PreviewProvider {
  static var previews: some View {
    AudioBreatheViewExt()
  }
}
#endif
