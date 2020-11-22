//
//  AudioPlayer.swift
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

/// This class is responsible for playing back audio files from a given `URL`.
///
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
  /// the `PassthroughSubject` property used for notifications
  let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
  /// property that indicates if audio is being played back.
  var isPlaying = false { didSet { objectWillChange.send(self) } }
  /// the `AVAudioPlayer` instance
  var audioPlayer: AVAudioPlayer!
  /// Function that is responsible for playing back the file at a given `URL`.
  ///
  /// - Parameter audio: the parameter of type `URL` that points to the audio file to play.
  ///
  func startPlayback (audio: URL) {
    do {
      // get the shared instance of the AVAudioSession
      let playbackSession = AVAudioSession.sharedInstance()
      // try to get a playback session
      try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
      // configure the player
      audioPlayer = try AVAudioPlayer(contentsOf: audio)
      // register ourselves as the delegation for the completion handler
      audioPlayer.delegate = self
      // now, playback the audio
      audioPlayer.play()
      // raise the playing flag
      isPlaying = true
    } catch {
      log.error("Playing over the device's speakers failed, reason: \(error).")
    }
  }
  /// Function that is responsible for stopping the playback.
  ///
  func stopPlayback() {
    audioPlayer.stop()
    isPlaying = false
  }
  /// Function that is the completion handler which fires once the playerback finishes.
  ///
  /// - Parameter player: the `AVAudioPlayer` instance that contains the audio player.
  ///
  /// - Parameter flag: the `Bool` flag which shows if it was successful or not.
  ///
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                   successfully flag: Bool) {
    // flip the isPlaying property if (successful completion) flag is up.
    if flag {
      log.info("Playback completion handler fired - playback was OK.")
      isPlaying = false
    } else {
      log.error("Playback completion handler fired - playback FAILED.")
    }
  }
}
