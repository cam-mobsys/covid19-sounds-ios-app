//
//  Utilities.swift
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
import UIKit
import DeviceKit

/// This is a class that has some convenience methods which can used
/// throughout.
///
class Utilities {
  private init() {}
  static let shared = Utilities()
  /// Password check regular expression template
//  let passRegEx = "^(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{6,20}$"
  let passRegEx = "^(?=.*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{6,20}$"
  /// Email check regular expression template
  let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
  /// Username check regular expression template
  let usernameRegEx = "^([A-Z0-9a-z]){2,20}$"
  /// Seed letters used for random string generation
  let randomStringSeedLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  /// default random string length used if we do not provide a parameter
  let randomStringDefaultLength = 12
  /// the divisor for kilobytes
  let kbDivisor = 1024
  //
  // MARK: - Random String related utilities
  //
  /// This is the default random string method which generates a random string using the default value
  /// stored in the `self.randomStringDefaultLength` value.
  ///
  /// - Returns: a string of length equal to `self.randomStringDefaultLength` value.
  ///
  func randomString() -> String {
    return self.randomString(len: self.randomStringDefaultLength)
  }
  /// This is an overloaded function that generates a random string of length `len`.
  ///
  /// - Parameter len: specifies the length of the random string.
  ///
  /// - Returns: a generated string of length `len`.
  ///
  func randomString(len: Int) -> String {
    return String((0..<len).map { _ in self.randomStringSeedLetters.randomElement()! })
  }
  //
  // MARK: - Device Related Utilities
  //
  /// Function that returns the expanded device operating system string.
  ///
  /// - Returns: the operating system description as `String`  along with version (e.g.: iOS,10.2.2).
  ///
  func getDeviceOS() -> String {
    return UIDevice.current.systemName + "," + UIDevice.current.systemVersion
  }
  /// Function that returns the device type (i.e: iPhone 8) as well as the OS type and version.
  ///
  /// - Returns: the device type as `String`,  operating system along with version (e.g.: iPhone 8, iOS,10.2.2).
  ///
  func getDeviceDescription() -> String {
    return "\(Device.current)" + "," + self.getDeviceOS()
  }
  /// This function generates a uuid string, based on the device's
  /// individual key; should be different for all devices except under
  /// unusual circumstances.
  ///
  /// - Parameter prefix: a boolean value checking if we have a prefixed
  ///                        `UUID` or not.
  ///
  /// - Returns: the uuid `String` of the device combined with "Device-ID-" prefix.
  ///
  func getDeviceID(prefix: Bool) -> String {
    if prefix {
      return "Device-ID-\(NSUUID().uuidString)"
    } else {
      return NSUUID().uuidString
    }
  }
  //
  // MARK: - Date Related Utilities
  //
  /// This function generates the time delta between two dates, which takes as arguments.
  /// The `from` date is the reference point and is assumed to be _LESS_ than `to`
  /// date which is our destination. It returns the elapses seconds passed between
  /// `from` and `to`. Note that `to` is an _optional_ if not supplied it is assumed to be
  /// the time of invocation.
  ///
  /// - Parameter from: the `Date` to get the `TimeInterval` from.
  ///
  /// - Parameter to: the (optional) `Date` to get the `TimeInterval`.
  ///
  /// - Returns: the  `TimeInterval` between `from` and `to`.
  ///
  func findTimeDelta(from: Date, to: Date?) -> TimeInterval {
    if let to_date = to {
      let elapsed = to_date.timeIntervalSince(from)
      return elapsed
    } else {
      let elapsed = Date().timeIntervalSince(from)
      return elapsed
    }
  }
  /// This function generates a human readable timestamp of the current
  /// time and returns it as a string.
  ///
  /// - Returns: the timestamp in a `String` format
  ///
  func getTimeStamp() -> String {
    // get the current date and time
    let currentDateTime = Date()
    // initialize the date formatter and set the style
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .medium
    // get the date time String from the date object the following would be:
    // October 8, 2016 at 10:48:53 PM
    return formatter.string(from: currentDateTime)
  }
  /// This function generates a human readable timestamp of the
  /// time given as an argument and returns it as a string.
  ///
  /// - Parameter interval: the `TimeInterval` we should generate the timestamp
  ///                      from (from unix time 1970)
  ///
  /// - Returns: the timestamp in a string format
  ///
  func getTimeStampForInterval(interval: TimeInterval) -> String {
    // get the proposed date and time
    let inputDate = Date(timeIntervalSince1970: interval)
    // initialize the date formatter and set the style
    // get the date time String from the date object the following would be:
    // October 8, 2016 at 10:48:53 PM
    return getDateFormatter(fmt: nil).string(from: inputDate)
  }
  /// This function generates a a timestamp as a `String` given a `Date` instance.
  /// The format of the timestamp would be: "October 8, 2016 at 10:48:53 PM"
  ///
  /// - Parameter date: the `Date` instance to create the timestamp for.
  ///
  /// - Returns: the generated timestamp as a `String`
  ///
  func getTimeStampForDate(date: Date) -> String {
    // get the date time String from the date object the following would be:
    // October 8, 2016 at 10:48:53 PM
    return getDateFormatter(fmt: nil).string(from: date)
  }
  /// This function creates a date formatter based on a default spec or creates a default one with
  /// the following format:  "October 8, 2016 at 10:48:53 PM", this means that `.timeStyle` is
  /// `.short` and `.dateStyle` is `.medium`.
  ///
  /// - Parameter `fmt`: a optional formatter instance, if `nil` we use the default one.
  ///
  /// - Returns: the `DateFormatter` instance.
  ///
  func getDateFormatter(fmt: DateFormatter?) -> DateFormatter {
    // get my formatter, after checking for nil
    let myFormatter = fmt ?? DateFormatter()
    // get the date time String from the date object the following would be:
    // October 8, 2016 at 10:48:53 PM
    myFormatter.timeStyle = .short
    myFormatter.dateStyle = .medium
    // finally return the formatter
    return myFormatter
  }
  /// This function generates a unix time from a given date.
  ///
  /// - Parameter `date`: the `date` optional
  ///
  /// - Returns: the unix time as `String`  of the `date` object, -1 otherwise.
  ///
  func getUnixTimeForDate(date: Date?) -> String {
    if let date = date {
      return date.timeIntervalSince1970.description
    } else {
      return "-1"
    }
  }
  /// This function takes an interval as a string and adds it to a date, if the conversion from `String`
  /// to `TimeInterval` is successful then the result is added to the suppled `date` which
  /// is then returned.
  ///
  /// - Parameter `interval`: the interval as a `String`
  ///
  /// - Parameter `date`: the `Date` to add the interval to.
  ///
  /// - Returns: the `date` plus the `interval` is conversion was succesful, `nil` otherwise.
  ///
  func addIntervalToDate(interval: String, date: Date) -> Date? {
    if let ts = TimeInterval(interval) {
      return date.addingTimeInterval(ts)
    } else {
      return nil
    }
  }
  //
  // MARK: - Validation & RegEx utilities
  //
  /// This function takes a string to perform the matching as well as a pattern
  /// to test against. To perform the comparison we use self matching from `NSPredicate`
  /// which is then evaluatated and the result of this evaluation returned.
  ///
  /// - Parameter str: the string to perform the matching
  ///
  /// - Parameter pat: the regular expression to perform the matching for
  ///
  /// - Returns: true if it matches, false if not
  ///
  func regexMatch(str: String, pat: String) -> Bool {
    let queryPredicate = NSPredicate(format: "SELF MATCHES %@", pat)
    return queryPredicate.evaluate(with: str)
  }
  /// This function tests if the provided string is a valid email
  ///
  /// - Parameter str: the string to perform the matching
  ///
  /// - Returns: `true` if this is a valid email, `false` otherwise
  ///
  func isValidEmail(str: String) -> Bool {
    return regexMatch(str: str, pat: emailRegEx)
  }
  /// This function tests if the provided string is a valid password as per our criteria
  ///
  /// - Parameter str: the `String` to perform the matching
  ///
  /// - Returns: `true` if this is a valid password, `false` otherwise
  ///
  func isValidPassword(str: String) -> Bool {
    return regexMatch(str: str, pat: passRegEx)
  }
  /// This function tests if the provided string is a valid username as per our criteria
  ///
  /// - Parameter `str`: the `String` to perform the matching
  ///
  /// - Returns: `true` if this is a valid username, `false` otherwise
  ///
  func isValidUsername(str: String) -> Bool {
    return regexMatch(str: str, pat: usernameRegEx)
  }
  /// This function is responsible for removing the extension of a path (string or full
  /// path).
  ///
  /// - Parameter `str`: the`String` or path to remove the extension from.
  ///
  /// - Returns: the filtered path as `String` without its extension.
  ///
  func filterExtension(str: String) -> String {
    return URL(fileURLWithPath: str).deletingPathExtension().lastPathComponent
  }
  /// This is a simple wrapper that check if a string is empty, ignoring any whitespaces
  ///
  /// - Parameter `str`: the `String` to check
  ///
  /// - Returns: `true` if the given `String` is empty, `false` otherwise.
  ///
  func isEmptyString(str: String) -> Bool {
    return str.trimmingCharacters(in: .whitespaces).isEmpty
  }
  //
  // MARK: - File utilities
  //
  /// This function takes a `url` and loads it in memory as `Data`.
  ///
  /// - Parameter url: the `URL` to load the file from.
  ///
  /// - Returns: the `Data` optional containing either the loaded data or `nil` in case of failure.
  ///
  func loadDataFromFile(url: URL) -> Data? {
    do {
      let data = try Data(contentsOf: url)
      return data
    } catch {
      log.error("Error while loading data from file \(url.description), reason: \(error.localizedDescription)")
      return nil
    }
  }
  /// This function gets the file size in kilobytes (kb) from `URL` if it exists.
  ///
  /// - Parameter url: the optional `URL` that holds the file location.
  ///
  /// - Returns: the file size in kilobytes as `Double` if `URL` is both valid and accessible, zero otherwise.
  ///
  func fileSizeFromURL(url: URL?) -> Double {
    guard let fp = url?.path else {
      return 0.0
    }
    do {
      let attr = try FileManager.default.attributesOfItem(atPath: fp)
      if let fileSize = attr[FileAttributeKey.size] as? NSNumber {
        return fileSize.doubleValue / 1024.0
      }
    } catch {
      log.error("Could not get file size, reason: \(error.localizedDescription)")
    }
    return 0.0
  }
  /// Function that finds the document path of the current user and
  /// returns the full path for the database.
  ///
  /// - Parameter dbName: the database filename as `String`.
  ///
  /// - Returns: the expanded database filename as a `URL`.
  ///
  func getDBPath(dbName: String) -> URL? {
    let fileManager: FileManager = FileManager.default
    do {
      let docDir = try fileManager.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
      let expandedFilename = docDir
        .appendingPathComponent(dbName, isDirectory: false)
      return expandedFilename
    } catch {
      // for debug reasons
      log.error("Failed to expand the path")
    }
    return nil
  }
}
