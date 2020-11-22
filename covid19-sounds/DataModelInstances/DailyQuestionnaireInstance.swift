//
//  DailyQuestionnaireInstance.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import SwiftyJSON
import Combine

/// The enumeration that describes the audio recording types, currently the following types
/// are supported:
///
/// - `breathe`: breathing recording.
/// - `read`: reading recording.
/// - `cough`: cough recording.
///
enum AudioRecordingType {
  case breathe, read, cough
}

/// Class that is used as an intermediate storing instance variables for the daily
/// survey that the participants are asked to perform. For persistence it is also stored
/// in CoreData.
///
class DailyQuestionnaireInstance: ObservableObject {
  // do it as asingleton
  private init() {}
  /// shared instance variable to access the singleton
  static let shared = DailyQuestionnaireInstance()
  /// variable the tracks object changes and sends the appropriate notifications.
  var didChange = PassthroughSubject<Void, Never>()
  /// holds the submitted  daily symptoms of the subject.
  var symptoms = "" { didSet { didChange.send() } }
  /// holds the submitted  covid status of the subject.
  var covidStatus = "" { didSet { didChange.send() } }
  /// holds the submitted hospital status of the subject.
  var hospitalStatus = "" { didSet { didChange.send() } }
  /// holds the url entry for the breathing audio file
  var breathingAudio: URL = URL(string: "/")! { didSet { didChange.send() } }
  /// holds the url entry for the coughing audio file
  var coughingAudio: URL = URL(string: "/")! { didSet { didChange.send() } }
  /// holds the url entry for the reading audio file
  var readingAudio: URL = URL(string: "/")! { didSet { didChange.send() } }
  /// Stores the user location in the form (lat, long)
  var location: String = "unavailable"
  /// Whether the location has been retrieved, used to navigate to the next view
  @Published var dailyQuestionnaireFilled = false
  /// Whether the data has uploaded successfully, used to show slert to user
  @Published var dataUploaded = false
  /// holds the audio file extensions used for the audio files
  static let audioFileExtension = "m4a"
  /// holds the breathing audio file name used for the form upload
  static let breathingAudioFilename = "audio_file_breathe"
  /// holds the coughing audio file name used for the form upload
  static let coughingAudioFilename = "audio_file_cough"
  /// holds the reading audio file name used for the form upload
  static let readingAudioFileName = "audio_file_read"
  /// holds the name for the ujpload file name entry
  static let jsonFilename = "daily.json"
  //
  // MARK: - General interface
  //
  /// Function that generates the filename for the form upload
  ///
  /// - Parameter `type`: the type of the audio recording `AudioRecordingType` dictates the filename for each case.
  ///
  /// - Returns: the constructed filename as`String` based on the type provided
  ///
  func formAudioFilename(type: AudioRecordingType) -> String {
    switch type {
    case .breathe:
      return DailyQuestionnaireInstance.breathingAudioFilename +
        "." +  DailyQuestionnaireInstance.audioFileExtension
    case .cough:
      return DailyQuestionnaireInstance.coughingAudioFilename +
        "." +  DailyQuestionnaireInstance.audioFileExtension
    case .read:
      return DailyQuestionnaireInstance.readingAudioFileName +
        "." + DailyQuestionnaireInstance.audioFileExtension
    }
  }
  /// This function rethrns the class representation as a `String`
  ///
  /// - Returns: the `String` representation of the class
  ///
  func toString() -> String {
    return """
    Symptoms: \(self.symptoms)
    Covid: \(self.covidStatus)
    Hospital: \(self.hospitalStatus)
    Breathe Audio: \(self.breathingAudio)
    Cough Audio: \(self.coughingAudio)
    Read Audio: \(self.coughingAudio)
    """
  }
  /// This function is responsible for getting the file size for each of the audio types we have
  ///
  /// - Parameter `type`: the `AudioRecordingType` to compute the file size.
  ///
  /// - Returns: the file size in kilobytes if successful, zero otherwise.
  ///
  private func getFilesize(_ type: AudioRecordingType) -> Double {
    switch type {
    case .breathe:
      return utils.fileSizeFromURL(url: self.breathingAudio)
    case .cough:
      return utils.fileSizeFromURL(url: self.coughingAudio)
    case .read:
      return utils.fileSizeFromURL(url: self.readingAudio)
    }
  }
  /// This function formats the audio to be used in the upload json; concretely is shows is the audio file is present
  /// along with its filesize, computed based on the file we have stored so far..
  ///
  /// - Parameter `type`: the `AudioRecordingType` to compute the string representation.
  ///
  /// - Returns: the `String` representation of the audio recording for the `JSON`.
  ///
  private func formatAudioURLForUpload(_ type: AudioRecordingType) -> String {
    switch type {
    case .breathe:
      return "present|\(getFilesize(.breathe))"
    case .cough:
      return "present|\(getFilesize(.cough))"
    case .read:
      return "present|\(getFilesize(.read))"
    }
  }
  /// This function is responsible for exporting the class contents as a `JSON`.
  ///
  /// - Returns: the `JSON` representation of the class entries.
  ///
  func toJSON() -> JSON {
    // construct the json
    let json: JSON = [
      "participant_id": userInstance.username,
      "datetime": userInstance.getCompletedTimeAsUnixTime(),
      "symptoms": self.symptoms,
      "covid": self.covidStatus,
      "hospital": self.hospitalStatus,
      "breathe": self.formAudioFilename(type: .breathe),
      "cough": self.formAudioFilename(type: .cough),
      "read": self.formAudioFilename(type: .read),
      "location": self.location,
      "locale": Locale.current.languageCode ?? "unknown",
      "device": utils.getDeviceDescription(),
      "type": entryType
    ]
    return json
  }
}
