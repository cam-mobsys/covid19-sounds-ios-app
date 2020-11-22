//
//  AudioRecorder.swift
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
import Combine
import AVFoundation

// configuration for the audio recorder
let recordingSamplingRate = 44100
let recordingBitRate = 192000
let recordingChannels = 2
let recordingQuality = AVAudioQuality.max.rawValue

/// Struct that holds the recording metadata, currently only its location (`URL`).
///
struct Recording {
  /// the recording file `URL`.
  let fileURL: URL
}

/// This class deals with the actual audio recording
///
class AudioRecorder: ObservableObject {
  /// the file path location of the audio file.
  var audioFilePath: URL = URL(string: "/")!
  /// the audio file type.
  private var audioType: String = ""
  /// the audio file extension.
  private var ext: String = ""
  /// the pass through notification to conform in the observable object.
  let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
  /// the audio recorder instance.
  var audioRecorder: AVAudioRecorder!
  /// the current recording instance.
  var currentRecording: Recording?
  /// flag indicating if we are recording.
  var recording = false { didSet { objectWillChange.send(self) } }
  /// flag indicating if we finished recording.
  var recorded = false { didSet { objectWillChange.send(self) } }
  /// Holds the recoding settings
  private let recordingSettings = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
    AVSampleRateKey: recordingSamplingRate,
    AVNumberOfChannelsKey: recordingChannels,
    AVEncoderAudioQualityKey: recordingQuality,
    AVEncoderBitRateKey: recordingBitRate
  ]
  /// The current duration of the recording.
  @Published var duration: Double = 0.0
  /// Function that requests the permissions and if granted executes a handler, if provided.
  ///
  /// - Parameter grantedHandler: the handler to be executed in case permissions are granted, if provided.
  ///
  /// - Parameter deniedHandler: the handler to be executed in case permissions are denied, if provided.
  ///
  func requestRecordingPermissions(grantedHandler: (() -> Void)? = nil,
                                   deniedHandler: (() -> Void)? = nil) {
    AVAudioSession.sharedInstance().requestRecordPermission({ (granted: Bool) -> Void in
      // should be granted
      if granted {
        log.info("Recording permissions have been granted.")
        // check if we have a handler to invoke
        if let handler = grantedHandler {
          log.info("Valid granted handler provided - invoking.")
          // invoke the handler
          DispatchQueue.main.async {
            handler()
          }
        } else {
          log.info("No valid granted handler provided - skipping invocation.")
        }
      } else {
        // permission not granted.
        log.error("Not granted, cannot record.")
        // check if we have a denied handler to invoke
        if let handler = deniedHandler {
          log.info("Valid denied handler provided - invoking.")
          DispatchQueue.main.async {
            handler()
          }
        } else {
          log.warning("No valid denied handler provided - skipping invocation.")
        }
      }
    })
  }
  /// This function is responsible for recording the required audio clip.
  ///
  /// - Parameter scene: the type description.
  ///
  /// - Parameter ext: the file extension.
  ///
  /// - Parameter recordHandler: the handler which is called when we start recording, if provided.
  ///
  /// - Parameter deniedHandler: the handler which deals with microphone permissions, if provided.
  ///
  func startRecording(scene: String,
                      ext: String,
                      recordHandler: (() -> Void)? = nil,
                      deniedHander: (() -> Void)? = nil) {
    // the audio type description (breate, cough, or read).
    self.audioType = scene
    // the extension of the file.
    self.ext = ext
    // now try to record after checking for permissions
    requestRecordingPermissions(grantedHandler: {self.record(handler: recordHandler)},
                                deniedHandler: deniedHander)
  }

  /// Function that constructs the audio path that the audio will be recorded at.
  ///
  /// - Returns: `URL` of the path.
  ///
  private func getAudioPath() -> URL {
    // get the top result
    let documentPath = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0]
    // add the extension
    let audioFP = documentPath.appendingPathComponent("\(self.audioType).\(self.ext)")
    log.info("Constructed audio path: \(audioFP)")
    //
    // finally return the path
    return audioFP
  }
  /// Internal function that is responsible for performing the recording.
  ///
  /// - Parameter handler: the handler to be invoked within the function during recording.
  ///
  private func record(handler: (() -> Void)?) {
    log.verbose("Entered record function")
    do {
      //
      if let deleteRecording = currentRecording {
        // try to delete the file
        log.verbose("Existing recording found; trying to delete the file at: \(deleteRecording.fileURL)")
        try FileManager.default.removeItem(at: deleteRecording.fileURL)
        log.verbose("Deleted previous recording file at: \(deleteRecording.fileURL)")
      } else {
        log.verbose("There was no previous recording present.")
      }
      // get the AVAudioSession instance
      let avSession = AVAudioSession.sharedInstance()
      //
      // set up the recording bits
      log.verbose("Setting up recorder")
      try avSession.setCategory(.playAndRecord, mode: .default)
      try avSession.setActive(true)
      log.verbose("Setup the recorder successfully")
      //
      // instantiate the audio recorder with the file path and recording settings
      log.verbose("Trying to create a recording session.")
      audioFilePath = getAudioPath()
      audioRecorder = try AVAudioRecorder(url: audioFilePath,
                                          settings: recordingSettings)
      //
      log.verbose("Created a recording session successfully.")
      //
      // finally record.
      log.verbose("Recording...")
      recording = true
      // check if our handler is valid, so we can invoke it.
      if handler != nil {
        log.info("Invoking record handler")
        handler!()
      }
      // now actually start recording.
      audioRecorder.record()
    } catch {
      log.error("Something unexpected happened while recording, reason: \(error)")
    }
    //
    // If previously recorded, hide play button
    //
    if recorded == true {
      log.info("Changing recorded from true to false")
      recorded = false
    }
    log.verbose("Record function execution completed.")
  }
  /// Function that stops the recording.
  ///
  func stopRecording() {
    log.verbose("Entered stop recording.")
    // get the current recording duration
    self.duration = audioRecorder.currentTime
    log.info("Stopping recording, total estimated recording duration is: \(duration)")
    // actually stop the recording.
    audioRecorder.stop()
    recording = false
    recorded = true
    // no assign the recorder clip and notify swiftui of change.
    self.assignRecording()
    log.verbose("Stop recording execution completed.")
  }
  /// This function is responsible for assigning the recoded clip to a recording instance; it also notifies swiftui
  /// of the change.
  ///
  private func assignRecording() {
    let recPath = getAudioPath()
    log.info("Assigning current recording from recorded clip at: \(recPath)")
    currentRecording = Recording(fileURL: recPath)
    log.info("Sending notificationg of object change.")
    objectWillChange.send(self)
  }
}
