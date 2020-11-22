//
//  UserInstance.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import Combine
import CoreData

/// User info instance, it is populated at the beginning of the execution or when
/// the user is created. For persistence it iscommited to `CoreData`.
///
class UserInstance: ModelProtocol, ObservableObject {
  /// the data service instance
  var dataService: DataService?
  /// do it as a singleton
  private init() {}
  /// shared instance variable to access the singleton
  static let shared = UserInstance()
  /// variable the tracks object changes and sends the appropriate notifications.
  var didChange = PassthroughSubject<Void, Never>()
  /// holds the username for the current app instance.
  var username = "" { didSet { didChange.send() } }
  /// holds the automatically generated password for the current app instance.
  var password = "" { didSet { didChange.send() } }
  /// holds the boolean indicating that the initial survey has indeed been uploaded.
  var uploadedInitial: Date? = nil { didSet { didChange.send() } }
  /// holds the flag if the user has provided consent.
  var initialQuestionnaireFilled = false { didSet { didChange.send() } }
  /// the timestamp to use for the completed time.
  var completedTime: Date? = nil { didSet { didChange.send() } }
  /// holds the flag which indicates if the user can upload today.
  @Published var canSubmitDailyQuestionnaire = true { didSet { didChange.send() } }
  //
  // MARK: - User instance management
  //
  /// Helper function that translates the currentl completed time to its string representation. If the time is nil,
  /// then the string returned is `-1`.
  ///
  /// - Returns: the `String` representation for the current time if non-nil, otherwise string value returned is: `-1`.
  ///
  func getCompletedTimeAsUnixTime() -> String {
    return utils.getUnixTimeForDate(date: self.completedTime)
  }
  /// Function that sets the survey completed time to the current time.
  ///
  func setCompletedTime() {
    self.completedTime = Date()
    log.info("Setting survey completed time to be: \(self.completedTime!)")
  }
  /// Simple function that checks if we have already uploaded an initial questionnaire.
  ///
  /// - Returns: `true` if we have uploaded it, `false` otherwise.
  ///
  func hasUploadedInitial() -> Bool {
    guard self.uploadedInitial != nil else {
      log.info("The user appears to have not yet uploaded an initial questionnaire.")
      return false
    }
    //
    // check if completed time is nil and if not check if it matches the uploaded initial.
    //
    if self.completedTime != nil {
      if self.uploadedInitial! == self.completedTime! {
        log.info("Upload initial and completed time match - need to upload initial survey")
        return false
      } else {
        log.info("Upload initial and completed dates mismatch; seems, initial survey uploaded already.")
        return true
      }
    }
    //
    log.info("The user appears to have uploaded an initial questionnaire.")
    return true
  }
  //
  // MARK: - CoreData protocol implementation
  //
  /// This function is responsible for updating the `CoreData` stored entities of type `T` which is in this case
  /// `User`.
  ///
  /// - Parameter entity: the parameter `T` which is `User` in this instance.
  ///
  /// - Parameter index: the index of the parameter to update, we get the first one by default.
  ///
  func updateCoreData<T>(entity: T, index: Int = 0) where T: NSManagedObject {
    // cast entity to User, if possible other wise return and log the error
    guard let user = entity as? User else {
      log.error("Failed to type cast the enity to User - cannot proceed")
      return
    }
    //
    log.info("Attempting to update the user model.")
    // check if we have a completed time, if not report and return.
    guard let completedTime = self.completedTime else {
      log.error("Attempting to save without having last completed time set, skipping.")
      return
    }
    // check if we have a valid username and password.
    if self.username.isEmpty || self.password.isEmpty {
      log.error("Username and/or password entries are empty - this should not happen; cannot save.")
      return
    } else {
      log.info("Setting username: \(username) and password: \(password)")
      user.username = username
      user.password = password
    }
    // log when the user completed the daily survey last
    log.info("User completed the daily survey at \(completedTime.description) which is being saved.")
    user.last_completed = completedTime
    // check if we need to set the initial questionnaire uploaded time as well.
    if user.uploaded_initial != nil {
      log.info("User has already uploaded the initial questionnaire, skipping.")
    } else {
      log.info("User has uploaded the initial questionnaire as well, setting upload initial date.")
      user.uploaded_initial = completedTime
      self.uploadedInitial = completedTime
    }
  }
  /// This function is responsible for updating the current `UserInstance` from `CoreData` fetched
  /// entities of type `T` which is in this case`User`.
  ///
  /// - Parameter entity: the parameter `T` which is `User` in this instance.
  ///
  /// - Parameter index: the index of the parameter to update, we get the first one by default.
  ///
  func updateInstance<T>(entity: T, index: Int = 0) where T: NSManagedObject {
    // cast entity to User, if possible other wise return and log the error.
    guard let user = entity as? User else {
      log.error("Failed to type cast the enity to User - cannot proceed")
      return
    }
    // check if any of the values are nil, when they should not be.
    guard
      let username = user.username,
      let password = user.password
      else {
        log.error("Values that should be non-nil they are - this unexpected.")
        return
    }
    //
    // check if the user has uploaded an initial survey.
    if let uploaded = user.uploaded_initial {
      log.info("User (\(user.username!)) seems to have uploaded an initial questionnaire.")
      self.uploadedInitial = uploaded
      // set the flag that the user has uploaded an initial survey to true.
      self.initialQuestionnaireFilled = true
    } else {
      log.error("User didn't upload initial questionnaire - leaving default.")
      return
    }
    //
    // now set them
    self.username = username
    self.password = password
    // guage if we can submit a daily questionnaire and set the flag accordingly.
    self.canSubmitDailyQuestionnaire = user.canSubmitDailyQuestionnaire()
    //
    // set to initial state and reset the daily questionnaire filled
    if self.canSubmitDailyQuestionnaire {
      appStatus.setInitialState()
      dailyQuestionnaireInstance.dailyQuestionnaireFilled = false
    }
    return
  }
  /// Function that is responsible for saving the `UserInstance` values to `CoreData`
  ///
  func save() {
    modelProcessor(User.self, optype: .save)
  }
  /// Function that is responsible for populating the `UserInstance` values from `CoreData`
  ///
  func populate() {
    modelProcessor(User.self, optype: .populate)
  }

}
