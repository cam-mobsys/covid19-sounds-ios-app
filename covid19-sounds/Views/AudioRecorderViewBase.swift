//
//  AudioRecorderViewBase.swift
//  covid19-sounds
//
//  Authors (order of contribution):
//
//    Andreas Grammenos
//    Api Hastanasombat
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import SwiftUI
import Combine

/// This is the generic view that is responsible for audio recording which is parameterised based on
/// the type of recording; in our case we have the following:
///
/// - breathing,
/// - cough, and
/// - read.
///
struct AudioRecorderViewBase: View {
  /// the `Binding` of the `AudioRecordingType` that parameterises the `AudioViewCore` based on the recording type.
  @Binding var recordingType: AudioRecordingType
  /// the `ObservedObject` of type `AudioRecorder` that is responsible for audio recorder.
  @ObservedObject var audioRecorder = AudioRecorder()
  /// the `ObservedObject` of type `AudioPlayer` that is responsible for audio player.
  @ObservedObject var audioPlayer = AudioPlayer()
  // the `DailyQuestionnaireInstance` instance as an `EnvironmentObject`.
  @EnvironmentObject private var dailyQuestionnaireInstance: DailyQuestionnaireInstance
  // the flag that shows an alert of the recording duration is lower than the allowed threshold.
  @State private var durationAlert = false
  // the flag that shows the audio permission denied view, if we do not have microphone access.
  @State private var showAudioPermissionDenied = false
  // the original time remaining for the recording - this gets set based on the time upon the start of recording.
  @State private var timeRemaining = -1
  // the countdown timer as a recurring event that fires every second, which we listen to.
  @State private var countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      // navigate away if the user has denied audio permissions
      if showAudioPermissionDenied {
        AudioPermissionDeniedView()
      } else {
        //
        Spacer()
        // Logic for displaying text
        // When recording is done
        if audioRecorder.recorded == true && audioPlayer.isPlaying == false {
          //
          TextViewFactory("postRecordingText")
          //
        }
        // When recording has not started
        else if audioRecorder.recording == false && audioPlayer.isPlaying == false {
          //
          PreRecordingTextFactory(self.recordingType)
          //
          // Recording is currently in progress
        } else if audioRecorder.recording == true && audioPlayer.isPlaying == false {
          //
          RecordingTextFactory(self.recordingType)
          //
        }
        //
        HStack {
          // Playback button logic
          // When recording is done and nothing is playing
          if audioRecorder.recorded == true && audioPlayer.isPlaying == false {
            //
            RecorderButtonViewFactory(action: {
              log.info("Play recorded clip button pressed.")
              if let rec = self.audioRecorder.currentRecording?.fileURL {
                self.audioPlayer.startPlayback(audio: rec)
              }
            }, fillName: playCircle)
            //
            // When recording is done and audio is currently playing
          } else if audioRecorder.recorded == true && audioPlayer.isPlaying == true {
            // playback stop fill button
            RecorderButtonViewFactory(action: {
              log.info("Stop playing recording button pressed")
              self.audioPlayer.stopPlayback()
            }, fillName: stopFill)
            //
          }
          //
          // Recording button logic, displayed when when _not_ *recording* nor *playing*
          //
          if audioRecorder.recording == false && audioPlayer.isPlaying == false {
            //
            RecorderButtonViewFactory(action: {
              log.info("\(self.recordingType) record button pressed.")
              // reset the timer according to the view required
              self.timeRemaining = Int(setTime(self.recordingType))
              // start recording pressed
              self.audioRecorder
                .startRecording(scene: getScene(self.recordingType),
                                ext: audioExt,
                                recordHandler: {
                                  log.info("Reseting timer")
                                  // cancel timer
                                  self.countdownTimer.upstream.connect().cancel()
                                  // reconnect it
                                  self.countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                                },
                                deniedHander: {
                                  log.error("Audio Permission denied, raising flag")
                                  self.showAudioPermissionDenied = true
                                })
            }, fillName: circleFill, foregroundColor: .red)
            //
            // When currently recording
          } else if audioRecorder.recording == true && audioPlayer.isPlaying == false {
            //
            VStack {
              //
              RecorderButtonViewFactory(action: {
                log.info("Stop recording button pressed for type \(self.recordingType).")
                self.audioRecorder.stopRecording()
                if self.audioRecorder.duration < 1 {
                  self.durationAlert = true
                  self.audioRecorder.recorded = false
                } else {
                  log.info("Canceling record timer.")
                  self.countdownTimer.upstream.connect().cancel()
                }
              }, fillName: stopFill, foregroundColor: .red)
              //
              Text("Time remaining: \(self.timeRemaining)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.black).opacity(0.7))
              //
            }
            //
          }
        }
        .alert(isPresented: self.$durationAlert) {
          Alert(title: Text("Invalid Recording"),
                message: Text("recordingDurationErrorText"),
                dismissButton: .default(Text("OK")))
        }
        //
        // Show navigation link if audio recorded and no audio is playing
        if audioRecorder.recorded == true && audioPlayer.isPlaying == false {
          RecordingNextView(recordingType: .constant(self.recordingType),
                            audioPath: .constant(self.audioRecorder.audioFilePath))
        }
        Spacer()
        //
      }
    }
    .modifier(AppBackgroundStyle())
    .onReceive(countdownTimer) { _ in
      if self.audioRecorder.recording && self.timeRemaining > 0 {
        self.timeRemaining -= 1
      } else if self.timeRemaining == 0 {
        // stop recording, if we do over zero.
        self.audioRecorder.stopRecording()
        log.info("Canceling timer due to time expiration.")
        self.countdownTimer.upstream.connect().cancel()
      }
    }
    .onAppear {
      log.info("Appeared - isPlaying: \(self.audioPlayer.isPlaying), Recorded: \(self.audioRecorder.recorded)")
    }
    .onDisappear {
      log.info("Audio recording view of type \(recordingType) will disappear")
      // check if we are recording
      if self.audioRecorder.recording {
        log.info("Audio recording view of type \(recordingType) is recoding " +
                  "- stopping while checking duration is within bounds")
        self.audioRecorder.stopRecording()
        if self.audioRecorder.duration < durationThreasholdCutoff {
          log.warning("Recorded audio durationg is lower than the allowed threshold \(durationThreasholdCutoff)")
          self.audioRecorder.recorded = false
        } else {
          log.info("Setting recorded as true since recording was \(self.audioRecorder.duration)" +
                    "seconds larger than the duration threshold of: \(durationThreasholdCutoff)")
          self.audioRecorder.recorded = true
        }
      }
      // now check if we are playing
      if self.audioPlayer.isPlaying {
        log.info("Audio is being played - stopping")
        self.audioPlayer.stopPlayback()
        self.audioPlayer.isPlaying = false
      }
      // notify that we are cancelling the counter
      log.info("Cancelling counter")
      self.countdownTimer.upstream.connect().cancel()
    }
  }
}

/// The get scene function is responsible for fetching the filename for each
/// particular recording type, indicated by `AudioRecordingType` enumeration.
///
/// - Parameter recordingType: the `AudioRecordingType` indicating the filename to use.
///
/// - Returns: the `String` with the filename for the given `AudioRecordingType`.
///
func getScene(_ recordingType: AudioRecordingType) -> String {
  switch recordingType {
  case .breathe:
    return DailyQuestionnaireInstance.breathingAudioFilename
  case .read:
    return DailyQuestionnaireInstance.readingAudioFileName
  case .cough:
    return DailyQuestionnaireInstance.coughingAudioFilename
  }
}

/// The set time function is responsible for fetching the stop threshold for each
/// particular recording type, indicated by `AudioRecordingType` enumeration.
///
/// - Parameter recordingType: the `AudioRecordingType` indicating the filename to use.
///
/// - Returns: the `Double` with the stop threshold for the given `AudioRecordingType`.
///
func setTime(_ recordingType: AudioRecordingType) -> Double {
  switch recordingType {
  case .breathe:
    return timerStopBreatheThreshold
  case .cough:
    return timerStopCoughThreshold
  case .read:
    return timerStopReadThreshold
  }
}

// only render this in debug mode
#if DEBUG
struct AudioCoreView_Previews: PreviewProvider {
  static var previews: some View {
    AudioRecorderViewBase(recordingType: .constant(AudioRecordingType.read),
                  audioRecorder: AudioRecorder(),
                  audioPlayer: AudioPlayer())
      .environmentObject(debugDailyQuestionnaireInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
