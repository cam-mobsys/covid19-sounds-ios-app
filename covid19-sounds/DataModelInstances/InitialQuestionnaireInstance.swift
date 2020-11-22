//
//  InitialQuestionnaireInstance.swift
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

/// Class that is used for storing for the initial info survey values during the
/// current execution. It does not persist its value across runs and is generated
/// when the app starts - note since this model is only used once we do not save
/// it to `CoreData` for privacy reasons.
///
class InitialQuestionnaireInstance: ObservableObject {
  /// do it singleton
  private init() {}
  /// shared instance variable to access the singleton
  static let shared = InitialQuestionnaireInstance()
  /// holds the name for the ujpload file name entry
  static let jsonFilename = "initial.json"
  /// variable the tracks object changes and sends the appropriate notifications.
  var didChange = PassthroughSubject<Void, Never>()
  /// holds the submitted  biological sex of the subject.
  var sex = "" { didSet { didChange.send() } }
  /// holds the submitted the age of the subject.
  var age = "" { didSet { didChange.send() } }
  /// holds the submitted medical conditions of the subject.
  var medicalHistory = "" { didSet { didChange.send() } }
  /// holds the submitted smoking history of the subject.
  var smokingHistory = "" { didSet { didChange.send() } }
  /// This function rethrns the class representation as a `String`
  ///
  /// - Returns: the `String` representation of the class
  ///
  func toString() -> String {
    return """
    Sex: \(self.sex)
    Age: \(self.age)
    Medical Conditions: \(self.medicalHistory)
    Smoking: \(self.smokingHistory)
    """
  }
  /// This function is responsible for exporting the class contents as a `JSON`
  ///
  /// - Returns: the `JSON` representation of the class entries.
  ///
  func toJSON() -> JSON {
    // construct the json
    let json: JSON = [
      "participant_id": userInstance.username,
      "datetime": userInstance.getCompletedTimeAsUnixTime(),
      "user_sex": self.sex,
      "user_age": self.age,
      "medical_history": self.medicalHistory,
      "smoking": self.smokingHistory,
      "locale": Locale.current.languageCode ?? "unknown",
      "device": utils.getDeviceDescription(),
      "type": entryType
    ]
    // finally, return it.
    return json
  }
}
