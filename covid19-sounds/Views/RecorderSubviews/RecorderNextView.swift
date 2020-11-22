//
//  RecorderNextView.swift
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

/// This view is responsible for directing the flow within the consecutive recording; it uses a generic
/// class for navigation, namely, `NavigationLinkFactory` which is parameterised by the `View`
/// to show next.
///
struct RecordingNextView: View {
  /// the `Binding` variable that indicates the `AudioRecordingType`
  @Binding var recordingType: AudioRecordingType
  /// the `Binding` variable that indicates the recording `URL`
  @Binding var audioPath: URL
  // the environment object that holds the daily questionnare instance
  @EnvironmentObject private var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      // NOTE: be careful - these indicate the _next_ destination for each case.
      //
      // Current plan is:
      //
      // .breathe -> AudioCoughViewExt
      //
      // .read -> LocationView
      //
      // .cough -> AudioReadViewExt
      //
      switch self.recordingType {
      case .breathe:
        NavigationLinkFactory<AudioCoughViewExt>(nextView: AudioCoughViewExt())
          .modifier(NavigationLinkModifier({
            setAudioRecordingFilePath(daily: self.dailyQuestionnaireInstance,
                                      audioPath: self.audioPath,
                                      recordingType: self.recordingType)
            log.info("\(self.recordingType) was set")
          }))
      case .read:
        NavigationLinkFactory<LocationViewExt>(nextView: LocationViewExt())
          .modifier(NavigationLinkModifier({
            setAudioRecordingFilePath(daily: self.dailyQuestionnaireInstance,
                                      audioPath: self.audioPath,
                                      recordingType: self.recordingType)
            log.info("\(self.recordingType) was set")
          }))
      case .cough:
        NavigationLinkFactory<AudioReadViewExt>(nextView: AudioReadViewExt())
          .modifier(NavigationLinkModifier({
            setAudioRecordingFilePath(daily: self.dailyQuestionnaireInstance,
                                      audioPath: self.audioPath,
                                      recordingType: self.recordingType)
            log.info("\(self.recordingType) was set")
          }))
      }
      // end of switch
    }
  }
}

/// This sets the audio recording file path
///
/// - Parameter daily: the `DailyQuestionnaireInstance` instance to set the path to
///
/// - Parameter audioPath: the `URL` that contains the path
///
/// - Parameter recordingType: the type of the recording which is `AudioRecordingType`
///
private func setAudioRecordingFilePath(daily: DailyQuestionnaireInstance,
                                       audioPath: URL,
                                       recordingType: AudioRecordingType) {
  switch recordingType {
  // handle the breathing type of recording
  case .breathe:
    daily.breathingAudio = audioPath
  // handle the cough type of recording
  case .cough:
    daily.coughingAudio = audioPath
  // handle the read type of recording
  case .read:
    daily.readingAudio = audioPath
  }
}

// only render this in debug mode
#if DEBUG
struct RecordingNextView_Previews: PreviewProvider {
  static var previews: some View {
    RecordingNextView(recordingType: .constant(.breathe),
                      audioPath: .constant(URL.init(string: "/")!))
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
