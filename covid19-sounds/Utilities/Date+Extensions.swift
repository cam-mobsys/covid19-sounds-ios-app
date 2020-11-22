//
//  Date+Extensions.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation

/// Useful extensios in the `Date` class
///
extension Date {
  /// This function takes a `DateFormatter` compatible `format`  as an argument and
  /// returns the timestamp as a string
  ///
  /// - Parameter `format`: String
  ///
  /// - Returns: the formatted `String` as per  `format`.
  ///
  func toString(dateFormat format: String) -> String {
    /// use the `DateFormatter` extension to return the required string.
    return DateFormatter(dateFormat: format).string(from: self)
  }
}
