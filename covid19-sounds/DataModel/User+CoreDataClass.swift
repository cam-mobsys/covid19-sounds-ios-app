//
//  User+CoreDataClass.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import CoreData

/// The `User` class that is used to store the object within `CoreData`.
///
public class User: NSManagedObject {
  #if DEBUG
  /// the next completion time delta for which to schedule a notification in `DEBUG` mode.
  private let NEXT_COMPLETION_TIME_DELTA: TimeInterval = 60
  #else
  /// the next completion time delta for which to schedule a notification.
  private let NEXT_COMPLETION_TIME_DELTA: TimeInterval = TWO_DAYS - 3600
  #endif
  /// This function is responsible for checking if the user can submit a daily questionnaire today.
  /// It is performed once the variable is instantiated and fetched from core data.
  ///
  /// - Returns `Bool`: `true` if allowed, `false` otherwise.
  ///
  public func canSubmitDailyQuestionnaire() -> Bool {
    // check if we have a value set for this, if not - always return false
    guard let lastDate = self.last_completed else {
      log.warning("Nil last date - returning true.")
      return true
    }
    // check when it was completed
    log.info("Got a valid date of last completion, that was: " +
              "\(utils.getTimeStampForDate(date: lastDate)), with " +
              "completion delta: \(NEXT_COMPLETION_TIME_DELTA)")
    // check if the delta is greater
    let timeDelta = utils.findTimeDelta(from: lastDate, to: nil)
    if timeDelta > NEXT_COMPLETION_TIME_DELTA {
      log.info("Time delta of \(timeDelta) was greater than the " +
                "threshold of \(NEXT_COMPLETION_TIME_DELTA) - returning true.")
      return true
    } else {
      log.info("Time delta of \(timeDelta) was lower than the " +
                "threshold of \(NEXT_COMPLETION_TIME_DELTA) - returning false.")
      return false
    }
  }
}
